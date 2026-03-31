#!/bin/bash
set -e

# Run casper-sidecar in the foreground as PID 1
echo "Starting casper-sidecar as user csidecar..."
export RUST_LOG="${RUST_LOG:-info}"

# Accept args from Kubernetes (e.g. --path-to-config ...).
if [ "$#" -eq 0 ]; then
	set -- --path-to-config /etc/casper-sidecar/config.toml
fi

# Container runs as csidecar; forward all args directly to sidecar.
exec /usr/bin/casper-sidecar "$@"
