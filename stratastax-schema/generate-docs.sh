#!/usr/bin/env bash
set -euo pipefail

MIGRATIONS_DIR="/build/resources/main/db/migration"
OUTPUT_DIR="/build/schema-docs"

NETWORK_NAME="stratastax-schema-docs-$$"
CONTAINER_NAME="stratastax-schema-docs-pg-$$"
DB_NAME="stratastax_docs"
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
  postgres:16-alpine > /dev/null

echo "Waiting for Postgres to accept connections..."
until docker exec "$CONTAINER_NAME" pg_isready -U "$DB_USER" > /dev/null 2>&1; do
  sleep 1
done

echo "Applying DDL migrations via Flyway..."
docker run --rm --network "$NETWORK_NAME" \
  -v "$(pwd)/${MIGRATIONS_DIR}:/migrations" \
  flyway/flyway:12.11.0 \
  -url="jdbc:postgresql://${CONTAINER_NAME}:5432/${DB_NAME}" \
  -user="$DB_USER" \
  -password="$DB_PASSWORD" \
  -locations="filesystem:/migrations" \
  -connectRetries=10 \
  migrate

echo "Generating documentation via tbls in: $(pwd)/${OUTPUT_DIR}"
TBLS_DSN="postgres://${DB_USER}:${DB_PASSWORD}@${CONTAINER_NAME}:5432/${DB_NAME}?sslmode=disable"
docker run --rm --network "$NETWORK_NAME" \
  -v "$(pwd)/${OUTPUT_DIR}:/out" \
  ghcr.io/k1low/tbls \
  doc --force "${TBLS_DSN}" /out

echo "Schema documentation written to ${OUTPUT_DIR}"