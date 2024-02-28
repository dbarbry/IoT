#!/bin/bash

# basic config
sudo -i

# cheking token
echo "[LOG] - Checking for token file"
if [ ! -f "/vagrant_shared/token" ]; then
    echo "Token file not found"
    exit 1
fi

# k3s
echo "[LOG] - Installing k3s"
echo "[LOG] - Master node: $1"
export K3S_TOKEN_FILE=/vagrant_shared/token
export K3S_URL=https://$1:6443
export INSTALL_K3S_EXEC="--flannel-iface=eth1"
curl -sfL https://get.k3s.io | sh -

# alias k for kubectl
echo "[LOG] - Alias for kubectl"
echo "alias k=kubectl" >> /etc/bash.bashrc
source /etc/bash.bashrc

# ifconfig
echo "[LOG] - Update path for ifconfig"
echo 'export PATH="/sbin:$PATH"' >> /etc/bash.bashrc
source /etc/bash.bashrc