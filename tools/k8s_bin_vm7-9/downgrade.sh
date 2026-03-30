# Run it from the control plane with a loop over all three pods:
for p in $(kubectl get pods -l app=myapp -o name); do
  echo "=== $p ==="
  kubectl exec -c app "${p#pod/}" -- su -s /bin/bash casper -c '
    rm -rf /etc/casper/2_2_1
    rm -rf /var/lib/casper/bin/2_2_1
  '
done
