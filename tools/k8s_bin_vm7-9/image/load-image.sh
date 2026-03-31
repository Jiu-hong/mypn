#!/bin/bash
# Run on host — saves casper-node and casper-sidecar images and loads them onto all worker nodes
set -e

BUILD_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker command not found. Install/start Docker on the build host."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker daemon is not reachable. Start docker.service on this host."
  exit 1
fi

build_and_load() {
  local IMAGE="$1"
  local DOCKERFILE="$BUILD_DIR/$2"
  local TMP="/tmp/${IMAGE%%:*}.tar"

  if [ ! -f "$DOCKERFILE" ]; then
    echo "ERROR: Dockerfile not found at $DOCKERFILE"
    exit 1
  fi

  echo "Building $IMAGE from $DOCKERFILE ..."

  DOCKER_BUILDKIT=0 docker build -t "$IMAGE" -f "$DOCKERFILE" "$BUILD_DIR"

  if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "ERROR: Build finished but $IMAGE is not in local Docker images."
    exit 1
  fi

  docker save -o "$TMP" "$IMAGE"
  tar -tf "$TMP" >/dev/null

  for vm in server07 server08 server09; do
    echo "--- Loading $IMAGE on $vm ---"
    scp "$TMP" "${vm}:/tmp/"
    ssh "$vm" "sudo ctr -n k8s.io images import $TMP"
  done
}

# Build base image first (local only — node and sidecar depend on it)
build_base() {
  local DOCKERFILE="$BUILD_DIR/casper-base.Dockerfile"
  if [ ! -f "$DOCKERFILE" ]; then
    echo "ERROR: Dockerfile not found at $DOCKERFILE"
    exit 1
  fi

  echo "Building casper-base:latest from $DOCKERFILE ..."
  DOCKER_BUILDKIT=0 docker build -t casper-base:latest -f "$DOCKERFILE" "$BUILD_DIR"
}

build_base
build_and_load "casper-node:latest"    "casper-node.Dockerfile"
build_and_load "casper-sidecar:latest" "casper-sidecar.Dockerfile"

echo "Done."
