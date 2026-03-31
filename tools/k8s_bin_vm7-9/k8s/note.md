# build image on host and load it onto all worker nodes

bash load-image.sh

# Apply the manifest

<!-- on control-plan server2604 -->

kubectl apply -f peers.yaml

# Watch pods come up

kubectl get pods -l app=myapp -o wide -w

# Check init container peer discovery logs

kubectl logs myapp-0 -c discover-peers
kubectl logs myapp-1 -c discover-peers
kubectl logs myapp-2 -c discover-peers

# Check app container startup logs

kubectl logs myapp-0 -c app --tail=200

# If any pod fails with image issues, verify image on each worker

ssh server07 'sudo ctr -n k8s.io images ls | grep casper-run'
ssh server08 'sudo ctr -n k8s.io images ls | grep casper-run'
ssh server09 'sudo ctr -n k8s.io images ls | grep casper-run'

# If needed, restart rollout after fixes

kubectl rollout restart statefulset/myapp
kubectl rollout status statefulset/myapp
