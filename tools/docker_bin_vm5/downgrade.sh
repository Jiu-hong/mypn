#!/bin/bash
set -e

docker exec casper-node bash -c "
  rm -rf /etc/casper/2_2_0
  rm -rf /var/lib/casper/bin/2_2_0
"
