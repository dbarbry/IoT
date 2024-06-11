#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# basic config
printf "${GREEN}[LINUX]${NC} - Getting updates...\n"
sudo apt-get update > /dev/null

# docker
printf "${GREEN}[DOCKER]${NC} - Installing docker...\n"
sudo apt-get install ca-certificates curl -y > /dev/null
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update > /dev/null

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y > /dev/null

# kubectl
printf "${GREEN}[KUBECTL]${NC} - Installing kubectl...\n"
if [ -d "./confs" ]; then
		sudo curl -Lo "./confs/kubectl" "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
		sudo curl -Lo "./confs/kubectl.sha256" "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
		sudo install -o root -g root -m 0755 ../confs/kubectl /usr/local/bin/kubectl
	else
		printf "${RED}[KUBECTL]${NC} - ./confs/ folder not found, but necessary.\n"
		exit 1
fi

# alias k for kubectl
printf "${GREEN}[KUBECTL]${NC} - Create aliases...\n"
echo "alias k=kubectl" >> /etc/bash.bashrc
source /etc/bash.bashrc
