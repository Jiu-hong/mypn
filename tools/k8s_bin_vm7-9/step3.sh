# On vm7, vm8, vm9 (join the cluster)
# After kubeadm init completes, it prints a kubeadm join command. Run it on each worker:
sudo kubeadm join 192.168.2.100:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>