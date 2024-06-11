#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# k3d
printf "${GREEN}[K3D]${NC} - Install and create cluster...\n"
if sudo k3d cluster list | grep -q 'kbarbry'; then
	printf "${RED}[K3D]${NC} - A cluster named 'kbarbry' already exists.\n"
	exit 1
else
	sudo wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	sudo k3d cluster create kbarbry --port 8080:80@loadbalancer --port 8888:8888@loadbalancer --port 80:80@loadbalancer --servers 1 --agents 3
fi
