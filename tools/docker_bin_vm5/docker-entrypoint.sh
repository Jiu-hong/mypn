#!/bin/bash
set -e

NETWORK_CONF_URL="http://mynetwork.local:5000/mynetwork/mynetwork.conf"
NETWORK_CONF_PATH="/etc/casper/network_configs/mynetwork.conf"

# Download network config
echo "Downloading network config..."
mkdir -p /etc/casper/network_configs
curl -fLo "$NETWORK_CONF_PATH" "$NETWORK_CONF_URL"

# check for validator key (must be provided via host mount)
if [ ! -f /etc/casper/validator_keys/secret_key.pem ]; then
    echo "ERROR: Validator key not found at /etc/casper/validator_keys/secret_key.pem"
    echo "Please ensure the host /etc/casper directory is mounted."
    exit 1
else
    echo "Validator key found."
fi
# Stage protocols (downloads bin.tar.gz and config.tar.gz for each version)
echo "Staging protocols..."
su -s /bin/bash casper -c "casper-node-util stage_protocols mynetwork.conf"

# detect latest protocol version
LATEST_VERSION=$(ls -d /etc/casper/[0-9]*_*/ 2>/dev/null | sort -V | tail -1 | xargs basename)
if [ -z "$LATEST_VERSION" ]; then
  echo "ERROR: No protocol version dirs found under /etc/casper/"
  exit 1
fi
echo "Latest protocol version: $LATEST_VERSION"

# set trusted_hash (unless INITIAL_VERSION is TRUE)
if [ "$INITIAL_VERSION" = "TRUE" ] || [ "$INITIAL_VERSION" = "true" ]; then
  echo "INITIAL_VERSION is true. Skipping trusted_hash update."
else
  echo "INITIAL_VERSION is not true (or unset). Setting trusted_hash..."
  TRUSTED_HASH=$(casper-client get-block --node-address http://192.168.2.101:7777 | jq -r .result.block_with_signatures.block.Version2.hash)
  if [ -z "$TRUSTED_HASH" ] || [ "$TRUSTED_HASH" = "null" ]; then
    echo "ERROR: Failed to get trusted_hash from node"
    exit 1
  fi
  sed -i "s/^#\?trusted_hash = .*/trusted_hash = '${TRUSTED_HASH}'/" /etc/casper/${LATEST_VERSION}/config.toml
fi

# set public_address to this machine's LAN IP (passed via -e LAN_IP in docker run)
if [ -z "$LAN_IP" ]; then
  echo "ERROR: LAN_IP environment variable is not set. Pass it with -e LAN_IP=<ip>"
  exit 1
fi
sed -i "s/^public_address = .*/public_address = '${LAN_IP}:0'/" /etc/casper/${LATEST_VERSION}/config.toml

# Run logrotate hourly in the background
while true; do logrotate /etc/logrotate.d/casper; sleep 3600; done &

# Run casper-node-launcher in the foreground as PID 1
echo "Starting casper-node-launcher as user casper..."
export RUST_LOG="${RUST_LOG:-info}"
mkdir -p /var/log/casper
chown -R casper:casper /var/log/casper

# Drop privileges to "casper" user
exec su -s /bin/bash casper -c "export RUST_LOG='${RUST_LOG}'; exec /usr/bin/casper-node-launcher" \
  1>> /var/log/casper/casper-node.log \
  2>> /var/log/casper/casper-node.stderr.log
