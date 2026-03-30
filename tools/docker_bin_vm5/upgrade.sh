#!/bin/bash
set -e

docker exec casper-node bash -c "
  curl -fLo /etc/casper/network_configs/mynetwork.conf http://mynetwork.local:5000/mynetwork/mynetwork.conf
  su -s /bin/bash casper -c 'casper-node-util stage_protocols mynetwork.conf'
  sed -i \"s/^public_address = .*/public_address = '\${LAN_IP}:0'/\" /etc/casper/2_2_0/config.toml
"
