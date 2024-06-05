#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

dots="..."
spaces="   "

# check permissions
if [ "$(id -u)" -ne 0 ] && [ -z "$SUDO_UID" ] && [ -z "$SUDO_USER" ]; then
	printf "${RED}[LINUX]${NC} - Permission denied. Please run the command with sudo privileges.\n"
	exit 87
fi

# check if all files are present
if [ -d "../confs" ] && [ -f "../confs/argocd-ingress.yaml" ] && [ -f "../confs/argocd-resource.yaml" ] && [ -f "../confs/dev-app.yaml" ] && [ -f "../confs/dev-ingress.yaml" ]; then
	printf "${GREEN}[LINUX]${NC} - All files found.\n"
else
	printf "${RED}[LINUX]${NC} - Script must be launched from script folder and confs folder must contains argocd-ingress.yaml, argocd-resource.yaml, dev-app.yaml and dev-ingress.yaml.\n"
	exit 1
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
if [ -d "../confs" ]; then
		sudo curl -Lo "../confs/kubectl" "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
		sudo curl -Lo "../confs/kubectl.sha256" "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
		sudo install -o root -g root -m 0755 ../confs/kubectl /usr/local/bin/kubectl
	else
		printf "${RED}[KUBECTL]${NC} - ../confs/ folder not found, but necessary.\n"
		exit 1
fi

# alias k for kubectl
printf "${GREEN}[KUBECTL]${NC} - Create aliases...\n"
echo "alias k=kubectl" >> /etc/bash.bashrc
source /etc/bash.bashrc

# k3d
printf "${GREEN}[K3D]${NC} - Install and create cluster...\n"
if sudo k3d cluster list | grep -q 'kbarbry'; then
	printf "${RED}[K3D]${NC} - A cluster named 'kbarbry' already exists.\n"
	exit 1
else
	sudo wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	sudo k3d cluster create kbarbry --port 8443:443@loadbalancer --port 8080:80@loadbalancer --servers 1 --agents 3
fi

# argocd
printf "${GREEN}[ARGOCD]${NC} - Create namespace...\n"
sudo kubectl create namespace argocd

# allow https
# printf "${GREEN}[ARGOCD]${NC} - Create SSL certificates...\n"
# if [ -d "../confs" ]; then
# 	sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ../confs/argocd.key -out ../confs/argocd.crt -subj "/CN=127.0.0.1/O=argocd"
# 	sudo kubectl create secret tls argocd-server-tls --key=../confs/argocd.key --cert=../confs/argocd.crt -n argocd
# else
# 	printf "${RED}[OPENSSL]${NC} - ../confs/ folder not found, but necessary.\n"
# 	exit 1
# fi

printf "${GREEN}[ARGOCD]${NC} - Install and launch app...\n"
if [ -d "../confs" ] && [ -f "../confs/argocd-resource.yaml" ]; then
	sudo kubectl apply -n argocd -f ../confs/argocd-resource.yaml > /dev/null
else
	printf "${RED}[ARGOCD]${NC} - ../confs/argocd-resource.yaml not found, but necessary.\n"
	exit 1
fi

# wait argocd pods running
printf "${GREEN}[ARGOCD]${NC} - Waiting for all pods to be running...\n"
while true; do
	running_pods=$(sudo kubectl get pods -n argocd --field-selector=status.phase=Running 2>/dev/null | grep -c "argocd")
	if [[ "$running_pods" -eq "7" ]]; then
		printf "\r${YELLOW}[ARGOCD]${NC} - Waiting...	(7/7)\n"
		printf "${GREEN}[ARGOCD]${NC} - All pods are running.\n"
		break
	else
		for (( i=1; i<=${#dots}; i++ )); do
			printf "\r${YELLOW}[ARGOCD]${NC} - Waiting${dots:0:$i}${spaces:($i-1):3}	($running_pods/7)"
			sleep 1
		done
	fi
done

# network settings
if [ -d "../confs" ] && [ -f "../confs/argocd-ingress.yaml" ]; then
	sudo kubectl apply -n argocd -f ../confs/argocd-ingress.yaml
else
	printf "${RED}[ARGOCD]${NC} - ../confs/argocd-ingress.yaml not found, but necessary.\n"
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
argocd login $server --username admin --password $password --insecure

# dev app
printf "${GREEN}[DEV]${NC} - Install and launch app...\n"
kubectl create namespace dev

if [ -d "../confs" ] && [ -f "../confs/dev-app.yaml" ]; then
	sudo kubectl apply -n argocd -f ../confs/dev-app.yaml > /dev/null
else
	printf "${RED}[ARGOCD]${NC} - ../confs/dev-app.yaml not found, but necessary.\n"
	exit 1
fi

if [ -d "../confs" ] && [ -f "../confs/dev-ingress.yaml" ]; then
	sudo kubectl apply -n dev -f ../confs/dev-ingress.yaml > /dev/null
else
	printf "${RED}[ARGOCD]${NC} - ../confs/dev-ingress.yaml not found, but necessary.\n"
	exit 1
fi

# print informations
printf "${GREEN}[ARGOCD]${NC} - Retrieving credentials...\n"

echo "argocd available at: http://localhost:8080/argocd"
echo "login: admin, password: $password"
