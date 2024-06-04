#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# check permissions
if [ "$(id -u)" -ne 0 ] && [ -z "$SUDO_UID" ] && [ -z "$SUDO_USER" ]; then
	printf "${RED}[LINUX]${NC} - Permission denied. Please run the command with sudo privileges.\n"
	exit 87
fi

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
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# alias k for kubectl
printf "${GREEN}[KUBECTL]${NC} - Create aliases...\n"
echo "alias k=kubectl" >> /etc/bash.bashrc
source /etc/bash.bashrc

# k3d
printf "${GREEN}[K3D]${NC} - Install and create cluster...\n"
if sudo k3d cluster list | grep -q 'kbarbry'
then
	printf "${RED}[K3D]${NC} - A cluster named 'kbarbry' already exists.\n"
	exit 1
else
	sudo wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	sudo k3d cluster create kbarbry --port 8080:80@loadbalancer
fi

# argocd
printf "${GREEN}[ARGOCD]${NC} - Install and launch app...\n"
sudo kubectl create namespace argocd
if [ -d "../confs" && -f "../confs/ressource.yaml" ]; then
	sudo kubectl apply -n argocd -f ../confs/ressource.yaml > /dev/null
else
	printf "${RED}[ARGOCD]${NC} - ../confs/ressource.yaml not found, but necessary.\n"
	exit 1
fi

# wait argocd pods running
printf "${GREEN}[ARGOCD]${NC} - Waiting for all pods to be running...\n"
while true; do
	running_pods=$(sudo kubectl get pods -n argocd --field-selector=status.phase=Running 2>/dev/null | grep -c "argocd")
	if [[ "$running_pods" -eq "7" ]]; then
		printf "${GREEN}[ARGOCD]${NC} - All pods are running.\n"
		break
	else
		printf "${YELLOW}[ARGOCD]${NC} - Waiting... ($running_pods/7).\n"
		sleep 3
	fi
done

# network settings
if [ -d "../confs" && -f "../confs/ingress.yaml" ]; then
	sudo kubectl apply -n argocd -f ../confs/ingress.yaml
else
	printf "${RED}[ARGOCD]${NC} - ../confs/ingress.yaml not found, but necessary.\n"
	exit 1
fi

# argocd cli
printf "${GREEN}[ARGOCD-CLI]${NC} - Install and launch CLI...\n"
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 > /dev/null
sudo chmod +x /usr/local/bin/argocd

# retrieving password
password=$(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

printf "${GREEN}[ARGOCD]${NC} - Login with admin account...\n"
server=$(sudo kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "$server"
argocd login $server --username admin --password $password --insecure > /dev/null

# dev app
printf "${GREEN}[DEV]${NC} - Install and create app...\n"
kubectl create namespace dev

# print informations
printf "${GREEN}[ARGOCD]${NC} - Retrieving credentials...\n"
password=$(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "argocd available at: http://localhost:8080/argocd"
echo "login: admin, password: $password"