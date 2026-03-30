#!/bin/bash
# Run on host — saves casper-run image and loads it onto all worker nodes
set -e

IMAGE=casper-run:latest
TMP=/tmp/casper-run.tar

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker command not found. Install/start Docker on the build host."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker daemon is not reachable. Start docker.service on this host."
  exit 1
fi

# Build image if missing.
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  BUILD_DIR="$REPO_ROOT/tools/k8s_bin_vm7-9/image"
  DOCKERFILE="$BUILD_DIR/run_node.Dockerfile"

  if [ ! -f "$DOCKERFILE" ]; then
    echo "ERROR: Dockerfile not found at $DOCKERFILE"
    exit 1
  fi

  echo "Image $IMAGE not found locally. Building from $DOCKERFILE ..."

  # Some hosts route builds through buildx; --load ensures the image is available to docker save.
  if docker buildx version >/dev/null 2>&1; then
    docker buildx build --load -t "$IMAGE" -f "$DOCKERFILE" "$BUILD_DIR"
  else
    docker build -t "$IMAGE" -f "$DOCKERFILE" "$BUILD_DIR"
  fi

  if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "ERROR: Build finished but $IMAGE is not in local Docker images."
    echo "If buildx is used, make sure --load is enabled."
    exit 1
  fi
fi

# Build tar from local Docker image.
docker save -o "$TMP" "$IMAGE"

# Quick sanity check so ctr does not fail on bad input.
tar -tf "$TMP" >/dev/null

for vm in server07; do
  echo "--- Loading image on $vm ---"
  scp "$TMP" "${vm}:/tmp/"
  ssh "$vm" "sudo ctr -n k8s.io images import /tmp/casper-run.tar"
done

echo "Done."
