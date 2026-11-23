#!/bin/sh
# Build the plant-aid image for the DigitalOcean nodes (linux/amd64) and push it
# to Docker Hub, tagged with the current commit hash and "latest".
set -e
IMAGE=chris687/plantaid-server
HASH=$(git rev-parse --short HEAD)
docker buildx build --platform linux/amd64 \
  -t "$IMAGE:$HASH" -t "$IMAGE:latest" \
  --push .
echo "Pushed image tag: $IMAGE:$HASH"
