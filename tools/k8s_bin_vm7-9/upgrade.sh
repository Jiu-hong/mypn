#!/bin/bash
set -e

# Run upgrade steps on all casper-node pods (DaemonSet on vm7-vm9)
# Equivalent of docker_bin_vm5/upgrade.sh using kubectl exec instead of docker exec

for pod in $(kubectl get pods -l app=casper-node -o jsonpath='{.items[*].metadata.name}'); do
  echo "--- Upgrading on $pod ---"
  kubectl exec "$pod" -- bash -c '
    curl -fLo /etc/casper/network_configs/mynetwork.conf http://mynetwork.local:5000/mynetwork/mynetwork.conf
    su -s /bin/bash casper -c "casper-node-util stage_protocols mynetwork.conf"
    sed -i "s/^public_address = .*/public_address = '"'"'${LAN_IP}:0'"'"'/" /etc/casper/2_2_0/config.toml
  '
done
