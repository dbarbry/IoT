#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# check installs to not reinstall
check_install() {
  local name=$1
  local command=$2
  local install_command=$3

  if $command &> /dev/null
  then
    echo -e "${GREEN}- $name is installed ${NC}\n"
  else
    echo -e "${YELLOW}- $name is not installed. Installing...${NC}\n"
    eval $install_command
    echo -e "${GREEN} $name has been successfully installed ${NC}\n"
  fi
}

# check permissions
if [ "$(id -u)" -ne 0 ] && [ -z "$SUDO_UID" ] && [ -z "$SUDO_USER" ]; then
	printf "${RED}[LINUX]${NC} - Permission denied. Please run the command with sudo privileges.\n"
	exit 87
fi

# basic config
printf "${GREEN}[LINUX]${NC} - Getting updates...\n"
apt-get update > /dev/null

# docker
printf "${GREEN}[DOCKER]${NC} - Installing docker...\n"
check_install "docker" "docker -v" "
apt-get install -y ca-certificates curl gnupg lsb-release
&& mkdir -m 0755 -p /etc/apt/keyrings
&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
&& echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null
&& apt-get update
&& apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
&& usermod -aG docker \$USER
"

# curl
check_install "curl" "curl --version" "apt-get install -y curl"

# kubectl
printf "${GREEN}[KUBECTL]${NC} - Installing kubectl...\n"
check_install "kubectl" "kubectl version --client" "
curl -LO \"https://dl.k8s.io/release/\$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl\"
&& chmod +x kubectl
&& mv kubectl /usr/local/bin/
"

# alias k for kubectl
printf "${GREEN}[KUBECTL]${NC} - Create aliases...\n"
echo "alias k=kubectl" >> /etc/bash.bashrc
source /etc/bash.bashrc

# install k3d
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
