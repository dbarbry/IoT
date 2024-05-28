#!/bin/bash

# basic config
sudo -i
apt-get update

# docker
apt-get -y install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# alias k for kubectl
echo "[LOG] - Alias for kubectl"
echo "alias k=kubectl" >> /etc/bash.bashrc
source /etc/bash.bashrc

# k3d
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
k3d cluster create kbarbry

# argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# for local access of argocd
# check the node port assigned with
# kubectl get svc argocd-server -n argocd
# kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# echo "ArgoCD admin password:"
# kubectl get pods -n argocd -o name | grep argocd-server | cut -d'/' -f 2 | xargs -I {} kubectl -n argocd logs {} | grep "password:"

# echo "ArgoCD server NodePort:"
# kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[0].nodePort}'