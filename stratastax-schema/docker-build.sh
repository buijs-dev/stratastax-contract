#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME=${1:-"stratastax-schema:latest"}
CONTEXT_DIR="build/docker-context"

echo "Building Docker image for linux/amd64: $IMAGE_NAME"

rm -rf "$CONTEXT_DIR"
mkdir -p "$CONTEXT_DIR"

cp src/main/docker/Dockerfile "$CONTEXT_DIR/"
cat src/main/docker/entrypoint.sh | tr -d '\r' > "$CONTEXT_DIR/entrypoint.sh"

mkdir -p "$CONTEXT_DIR/db"
cp -r src/main/resources/db/migration "$CONTEXT_DIR/db/"

docker build --platform linux/amd64 -t "$IMAGE_NAME" "$CONTEXT_DIR"

echo "Successfully built $IMAGE_NAME"