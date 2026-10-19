#!/usr/bin/env bash
set -euo pipefail

# Verifies the migrations of one service against a throwaway Postgres:
#   1. applies the versioned migrations (`v1`) and then the seed data (`testdata`), the latter with
#      its own history table (flyway_testdata_history), exactly as a dev or test database does;
#   2. checks the rules of NAMING.md that the database can see: every constraint and index is
#      named by convention, no foreign key is declared twice or points at a public_id, every
#      foreign key column is indexed, every table with a public_id has created_at and updated_at;
#   3. checks the seed data (src/main/verify-migrations/seed-data.sql and <service>.sql);
#   4. builds a second database the same way and compares a fingerprint of all data, so the seed
#      data is proven deterministic.
#
# usage: verify-migrations.sh <engine|game-catalog|i18n>
SERVICE=${1:?"usage: verify-migrations.sh <engine|game-catalog|i18n>"}
MIGRATIONS_DIR="src/main/resources/db/migration/${SERVICE}"
CHECKS_DIR="src/main/verify-migrations"

POSTGRES_IMAGE="postgres:18-alpine"
FLYWAY_IMAGE="flyway/flyway:12.11.0"

if [ ! -d "$MIGRATIONS_DIR/v1" ]; then
  echo "No migrations in ${MIGRATIONS_DIR}/v1" >&2
  exit 1
fi

NETWORK_NAME="stratastax-schema-verify-${SERVICE}-$$"
CONTAINER_NAME="stratastax-schema-verify-pg-${SERVICE}-$$"
DB_USER="verify"
DB_PASSWORD="verify"

cleanup() {
  docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1 || true
  docker network rm "$NETWORK_NAME" > /dev/null 2>&1 || true
}

trap cleanup EXIT

docker network create "$NETWORK_NAME" > /dev/null

docker run -d --name "$CONTAINER_NAME" --network "$NETWORK_NAME" \
  -e POSTGRES_DB=first \
  -e POSTGRES_USER="$DB_USER" \
  -e POSTGRES_PASSWORD="$DB_PASSWORD" \
  "$POSTGRES_IMAGE" > /dev/null

echo "Waiting for Postgres to accept connections..."
until docker exec "$CONTAINER_NAME" pg_isready -U "$DB_USER" -d first > /dev/null 2>&1; do
  sleep 1
done

psql() {
  docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$1" -v ON_ERROR_STOP=1 -qAt
}

flyway() {
  local db=$1 location=$2
  shift 2
  docker run --rm --network "$NETWORK_NAME" \
    -v "$(pwd)/${MIGRATIONS_DIR}/${location}:/migrations:ro" \
    "$FLYWAY_IMAGE" \
    -url="jdbc:postgresql://${CONTAINER_NAME}:5432/${db}" \
    -user="$DB_USER" \
    -password="$DB_PASSWORD" \
    -locations="filesystem:/migrations" \
    -connectRetries=10 \
    "$@" \
    migrate > /dev/null
}

build_database() {
  local db=$1
  echo "Building database ${db}: v1, then testdata"
  flyway "$db" v1
  flyway "$db" testdata -table=flyway_testdata_history -baselineOnMigrate=true -baselineVersion=0
}

fingerprint() {
  # One md5 per table over all its rows, in a stable order; the history tables are left out. The
  # created_at and updated_at of reference data in `v1` (pipeline_control) are now(), so these two
  # columns are left out here; that the seed data sets them itself is checked in seed-data.sql.
  psql "$1" <<'SQL'
SELECT string_agg(
         format('SELECT %L, md5(coalesce(string_agg((to_jsonb(t) - %L - %L)::text, %L ORDER BY (to_jsonb(t) - %L - %L)::text), %L)) FROM %I t',
                tablename, 'created_at', 'updated_at', '|', 'created_at', 'updated_at', '', tablename),
         ' UNION ALL ' ORDER BY tablename)
FROM pg_tables
WHERE schemaname = 'public' AND tablename NOT LIKE 'flyway%'
\gexec
SQL
}

until psql first <<< "SELECT 1" > /dev/null 2>&1; do sleep 1; done
psql first <<< "CREATE DATABASE second"

build_database first

echo "Checking naming and structure..."
VIOLATIONS=$(psql first < "${CHECKS_DIR}/structure.sql")
if [ -n "$VIOLATIONS" ]; then
  echo "Structure violations:" >&2
  echo "$VIOLATIONS" >&2
  exit 1
fi

echo "Checking the seed data..."
VIOLATIONS=$(cat "${CHECKS_DIR}/seed-data.sql" "${CHECKS_DIR}/${SERVICE}.sql" | psql first)
if [ -n "$VIOLATIONS" ]; then
  echo "Seed data violations:" >&2
  echo "$VIOLATIONS" >&2
  exit 1
fi

build_database second

echo "Comparing the data of both databases..."
FIRST=$(fingerprint first)
SECOND=$(fingerprint second)
if [ "$FIRST" != "$SECOND" ]; then
  echo "The seed data is not deterministic; tables that differ:" >&2
  diff <(echo "$FIRST") <(echo "$SECOND") >&2 || true
  exit 1
fi

echo "Migrations of ${SERVICE} verified: $(echo "$FIRST" | wc -l | tr -d " ") tables, identical in both databases"
