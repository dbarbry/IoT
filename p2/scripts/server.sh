#!/bin/bash

# basic config
apt update -y

# k3s
echo "[LOG] - Installing k3s"
export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="--server --cluster-init --bind-address=$1 --node-external-ip=$1 --flannel-iface=eth1"
curl -sfL https://get.k3s.io | sh -
if [ $? -ne 0 ]; then
    echo "Failed to install k3s. Exiting."
    exit 1
fi

# alias k for kubectl
echo "[LOG] - Alias for kubectl"
echo "alias k=kubectl" >> /etc/bash.bashrc
source /etc/bash.bashrc

# ifconfig
echo "[LOG] - Update path for ifconfig"
echo 'export PATH="/sbin:$PATH"' >> /etc/bash.bashrc
source /etc/bash.bashrc

# deployment part
echo "[P1] - Initiating..."
kubectl create configmap app-one-html --from-file /vagrant_shared/app1/index.html
kubectl apply -f /vagrant_shared/app1/deployment.yaml
kubectl apply -f /vagrant_shared/app1/service.yaml
echo "[P1] - Done"

echo "[P2] - Initiating..."
kubectl create configmap app-two-html --from-file /vagrant_shared/app2/index.html
kubectl apply -f /vagrant_shared/app2/deployment.yaml
kubectl apply -f /vagrant_shared/app2/service.yaml
echo "[P2] - Done"

echo "[P3] - Initiating..."
kubectl create configmap app-three-html --from-file /vagrant_shared/app3/index.html
kubectl apply -f /vagrant_shared/app3/deployment.yaml
kubectl apply -f /vagrant_shared/app3/service.yaml
echo "[P3] - Done"

echo "[Ingress] - Initiating..."
kubectl apply -f /vagrant_shared/ingress.yaml
echo "[Ingress] - Done"
