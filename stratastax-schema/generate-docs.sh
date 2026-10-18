#!/usr/bin/env bash
set -euo pipefail

# Generates Markdown + SVG (ER diagram) schema documentation of one service with tbls, from a
# throwaway Postgres that only gets the versioned migrations (`v1`, never `testdata`). The output
# is published on docs.stratastax.dev, so it must not contain data or connection details; see
# tbls.yml for what is left out.
#
# usage: generate-docs.sh <engine|game-catalog|i18n> [output-dir]
#   output-dir defaults to build/schema-docs/<service>; run `./gradlew jar` first, the migrations
#   are read from build/resources/main.
SERVICE=${1:?"usage: generate-docs.sh <engine|game-catalog|i18n> [output-dir]"}
OUTPUT_DIR=${2:-"build/schema-docs/${SERVICE}"}
MIGRATIONS_DIR="build/resources/main/db/migration/${SERVICE}/v1"

POSTGRES_IMAGE="postgres:18-alpine"
FLYWAY_IMAGE="flyway/flyway:12.11.0"
TBLS_IMAGE="ghcr.io/k1low/tbls:v1.94.5"

if [ ! -d "$MIGRATIONS_DIR" ]; then
  echo "No migrations in ${MIGRATIONS_DIR}; run ./gradlew jar first" >&2
  exit 1
fi
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR=$(cd "$OUTPUT_DIR" && pwd)

NETWORK_NAME="stratastax-schema-docs-${SERVICE}-$$"
CONTAINER_NAME="stratastax-schema-docs-pg-${SERVICE}-$$"
DB_NAME="${SERVICE//-/_}"
DB_USER="docs"
DB_PASSWORD="docs"

cleanup() {
  docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1 || true
  docker network rm "$NETWORK_NAME" > /dev/null 2>&1 || true
}

trap cleanup EXIT

docker network create "$NETWORK_NAME" > /dev/null

docker run -d --name "$CONTAINER_NAME" --network "$NETWORK_NAME" \
  -e POSTGRES_DB="$DB_NAME" \
  -e POSTGRES_USER="$DB_USER" \
  -e POSTGRES_PASSWORD="$DB_PASSWORD" \
  "$POSTGRES_IMAGE" > /dev/null

echo "Waiting for Postgres to accept connections..."
until docker exec "$CONTAINER_NAME" pg_isready -U "$DB_USER" -d "$DB_NAME" > /dev/null 2>&1; do
  sleep 1
done

echo "Applying the ${SERVICE} migrations via Flyway..."
docker run --rm --network "$NETWORK_NAME" \
  -v "$(pwd)/${MIGRATIONS_DIR}:/migrations:ro" \
  "$FLYWAY_IMAGE" \
  -url="jdbc:postgresql://${CONTAINER_NAME}:5432/${DB_NAME}" \
  -user="$DB_USER" \
  -password="$DB_PASSWORD" \
  -locations="filesystem:/migrations" \
  -connectRetries=10 \
  migrate

echo "Generating documentation via tbls in: ${OUTPUT_DIR}"
docker run --rm --network "$NETWORK_NAME" \
  -v "$(pwd)/tbls.yml:/work/tbls.yml:ro" \
  -v "${OUTPUT_DIR}:/out" \
  -w /work \
  -e TBLS_DSN="postgres://${DB_USER}:${DB_PASSWORD}@${CONTAINER_NAME}:5432/${DB_NAME}?sslmode=disable" \
  -e TBLS_DOC_PATH=/out \
  -e TBLS_NAME="$SERVICE" \
  "$TBLS_IMAGE" \
  doc --force --config /work/tbls.yml

echo "Schema documentation written to ${OUTPUT_DIR}"
