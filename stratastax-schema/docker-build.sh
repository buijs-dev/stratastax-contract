#!/usr/bin/env bash
set -euo pipefail

# usage: docker-build.sh <service> [image-name]
#   service: the migration subdirectory, engine or game-catalog
SERVICE=${1:?"usage: docker-build.sh <engine|game-catalog> [image-name]"}
IMAGE_NAME=${2:-"database-schema-${SERVICE}:latest"}
CONTEXT_DIR="build/docker-context/${SERVICE}"

echo "Building Docker image for linux/amd64: $IMAGE_NAME (migrations: ${SERVICE}/v1)"

rm -rf "$CONTEXT_DIR"
mkdir -p "$CONTEXT_DIR/db/migration"

cp src/main/docker/Dockerfile "$CONTEXT_DIR/"
cat src/main/docker/entrypoint.sh | tr -d '\r' > "$CONTEXT_DIR/entrypoint.sh"

# Only the service's own versioned migrations; test data never goes into an image.
mkdir -p "$CONTEXT_DIR/db/migration/${SERVICE}"
cp -r "src/main/resources/db/migration/${SERVICE}/v1" "$CONTEXT_DIR/db/migration/${SERVICE}/"

docker build --platform linux/amd64 --build-arg SERVICE="${SERVICE}" -t "$IMAGE_NAME" "$CONTEXT_DIR"

echo "Successfully built $IMAGE_NAME"
