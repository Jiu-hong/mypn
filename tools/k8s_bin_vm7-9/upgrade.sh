# Run it from the control plane with a loop over all three pods:
for p in myapp-0 myapp-1 myapp-2; do
  echo "=== $p ==="
  kubectl exec -c app "${p#pod/}" -- su -s /bin/bash casper -c 'casper-node-util stage_protocols mynetwork.conf'
  kubectl exec -c app "$p" -- sh -ceu '
    . /peer/peers.env

    NEW_VER=$(ls -d /etc/casper/[0-9]*_*/ 2>/dev/null | sort -V | tail -1 | xargs basename)
    CFG="/etc/casper/${NEW_VER}/config.toml"

    # update public_address
    sed -i "s|^public_address = .*|public_address = '\''${OWN_IP}:0'\''|" "$CFG"

    # rebuild known_addresses from discovered peers
    PEER_LIST=""
    for i in 0 1 2; do
      eval IP=\${PEER_${i}_IP:-}
      if [ -n "${IP}" ]; then
        PEER_LIST="${PEER_LIST}${PEER_LIST:+, }'\''${IP}:35000'\''"
      fi
    done

    sed -i "s|^known_addresses = .*|known_addresses = [${PEER_LIST}]|" "$CFG"

    echo "Updated ${CFG}"
    grep -E "^(public_address|known_addresses) = " "$CFG"
  '
done

# If you want it to auto-discover pods by label instead of hardcoding names:
for p in $(kubectl get pods -l app=myapp -o name); do
  echo "=== $p ==="
  kubectl exec -c app "${p#pod/}" -- su -s /bin/bash casper -c 'casper-node-util stage_protocols mynetwork.conf'
done

# Quick verify after running:
for p in myapp-0 myapp-1 myapp-2; do
  echo "=== $p ==="
  kubectl exec -c app "$p" -- ls -1 /etc/casper | grep -E '^[0-9]+_[0-9]+_[0-9]+$' || true
done