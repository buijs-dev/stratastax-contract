#!/usr/bin/env bash
set -euo pipefail

LOCAL_IMAGE=$1
REGISTRY_URL=$2
REMOTE_TAG=$3
USERNAME=${4:-""}
PASSWORD=${5:-""}

REMOTE_IMAGE="$REGISTRY_URL/$LOCAL_IMAGE"

if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    REGISTRY_HOST=$(echo "$REGISTRY_URL" | cut -d'/' -f1)
    echo "Logging in to $REGISTRY_HOST..."
    echo "$PASSWORD" | docker login "$REGISTRY_HOST" -u "$USERNAME" -p "$PASSWORD"
fi

echo "Pushing Docker image..."
echo "Local image: $LOCAL_IMAGE"
echo "Remote image: $REMOTE_IMAGE"

docker tag "$LOCAL_IMAGE" "$REMOTE_IMAGE"
docker push "$REMOTE_IMAGE"

echo "Successfully pushed $REMOTE_IMAGE"
