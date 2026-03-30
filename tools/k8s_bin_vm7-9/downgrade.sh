#!/bin/bash
set -e

# Remove the new protocol version from all casper-node pods (DaemonSet on vm7-vm9)
# Equivalent of docker_bin_vm5/downgrade.sh using kubectl exec instead of docker exec

for pod in $(kubectl get pods -l app=casper-node -o jsonpath='{.items[*].metadata.name}'); do
  echo "--- Downgrading on $pod ---"
  kubectl exec "$pod" -- bash -c '
    rm -rf /etc/casper/2_2_0
    rm -rf /var/lib/casper/bin/2_2_0
  '
done
