#!/bin/bash
# Run on host — saves casper-run image and loads it onto all worker nodes
set -e

IMAGE=casper-run:latest
TMP=/tmp/casper-run.tar

echo "Saving image $IMAGE from vm5..."
ssh vm5 "docker save $IMAGE" > "$TMP"

for vm in server07 server08 server09; do
  echo "--- Loading image on $vm ---"
  scp "$TMP" "${vm}:/tmp/"
  ssh "$vm" "sudo ctr -n k8s.io images import /tmp/casper-run.tar"
done

echo "Done."
