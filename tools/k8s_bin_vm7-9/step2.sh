# On control plane (server2604) only

sudo kubeadm init \
 --control-plane-endpoint=192.168.2.113 \
 --pod-network-cidr=10.244.0.0/16 \
 --apiserver-advertise-address=192.168.2.113

# Set up kubeconfig

mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel CNI (network plugin)

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
