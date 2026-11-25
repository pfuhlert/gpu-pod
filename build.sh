#!/bin/bash
# Build the container image and push it to the registry.
# Usage: ./build.sh
set -euo pipefail
cd "$(dirname "$0")"
source ./_load_env.sh

IMAGE_TAG="$REMOTE_REGISTRY/$APPNAME:$APPVERSION"

echo "Logging in to '$REMOTE_REGISTRY' ..."
podman login "$REMOTE_REGISTRY"

echo "Building '$IMAGE_TAG' ..."
podman build -t "$IMAGE_TAG" \
  --build-arg USERNAME="$USERNAME" \
  --build-arg USER_UID="$USER_UID" \
  --build-arg USER_GID="$USER_GID" \
  --build-arg GIT_NAME="$GIT_NAME" \
  --build-arg GIT_EMAIL="$GIT_EMAIL" \
  -f Dockerfile .

echo "Pushing '$IMAGE_TAG' ..."
podman push "$IMAGE_TAG"

echo "Done. Start the pod with ./start.sh"
