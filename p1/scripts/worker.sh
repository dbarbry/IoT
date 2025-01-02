#!/bin/bash

# basic config
apt update -y

# cheking token
echo "[LOG] - Checking for token file"
TIMEOUT=10
while [ ! -f "/vagrant_shared/token" ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
    if [ "$TIMEOUT" -eq 0 ]; then
        echo "Token file not found."
        exit 1
    fi
done

# k3s
echo "[LOG] - Installing k3s"
echo "[LOG] - Master node: $1"
export K3S_TOKEN_FILE=/vagrant_shared/token
export K3S_URL=https://$1:6443
export INSTALL_K3S_EXEC="--flannel-iface=eth1"
curl -sfL https://get.k3s.io | sh -
if [ $? -ne 0 ]; then
    echo "Failed to install k3s. Exiting."
    exit 1
fi

# alias k for kubectl
echo "[LOG] - Alias for kubectl"
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-aliases.sh > /dev/null

# ifconfig
echo "[LOG] - Update path for ifconfig"
echo 'export PATH="/sbin:$PATH"' >> /etc/bash.bashrc
source /etc/bash.bashrc