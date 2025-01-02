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

# share token
echo "[LOG] - Share token"
TIMEOUT=30
while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
    if [ "$TIMEOUT" -eq 0 ]; then
        echo "Token file not generated in 30sec"
        exit 1
    fi
done
cp /var/lib/rancher/k3s/server/node-token /vagrant_shared/token

# alias k for kubectl
echo "[LOG] - Alias for kubectl"
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-aliases.sh > /dev/null

# ifconfig
echo "[LOG] - Update path for ifconfig"
echo 'export PATH="/sbin:$PATH"' >> /etc/bash.bashrc
source /etc/bash.bashrc
