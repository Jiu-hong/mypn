# === RECOVERY: kube-apiserver crash (corrupted etcd state) ===
# Root cause: PostStartHook "crd-informer-synced" fails instantly due to
# inconsistent etcd data from earlier crash loop. Fix: full reset + reinit.

# Step 0 — Reset workers (run on vm7, vm8, vm9):
# ssh vm7 "sudo kubeadm reset -f"
# ssh vm8 "sudo kubeadm reset -f"
# ssh vm9 "sudo kubeadm reset -f"

# Step 1 — Reset control plane (on host):
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F
sudo ipvsadm --clear 2>/dev/null || true

# Step 2 — Reinit control plane (on host):
sudo kubeadm init \
  --control-plane-endpoint=192.168.2.100 \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=192.168.2.100

mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Step 3 — Get new join command and rejoin workers:
kubeadm token create --print-join-command
# Run the printed "kubeadm join ..." on vm7, vm8, vm9

# Step 4 — Verify all nodes Ready:
kubectl get nodes

# Step 4b — Restore NAT rules for VM internet access (wiped by kubeadm reset)
sudo iptables -A FORWARD -i enp7s0 -o tun0 -j ACCEPT
sudo iptables -A FORWARD -i tun0 -o enp7s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o tun0 -j MASQUERADE

# === DEPLOY casper-node ===

# Step 5 — Load image onto workers:
chmod +x tools/k8s_bin_vm7-9/load-image.sh
source tools/k8s_bin_vm7-9/load-image.sh

# Step 6 — Deploy:
kubectl apply -f ppers.yaml

# Step 7 — Verify:
kubectl get pods -o wide   # should show 3 pods, one per worker node
kubectl logs -f daemonset/casper-node