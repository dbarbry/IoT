#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

USERNAME=$(whoami)

# k3d
printf "${GREEN}[K3D]${NC} - Install and create cluster...\n"
if sudo k3d cluster list | grep -q "$USERNAME"; then
	printf "${RED}[K3D]${NC} - A cluster named $USERNAME already exists.\n"
	exit 1
else
	if ! sudo k3d cluster create $USERNAME --port 80:80 --servers 1 --agents 3; then
        echo -e "${RED}[K3D]${NC} - Cluster creation failed! Do you have k3d installed and is the Docker service running?${NC}"
        exit 1
    fi
fi

export KUBECONFIG="$(sudo k3d kubeconfig write "$USERNAME")"