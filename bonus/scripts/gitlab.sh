#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

dots="..."
spaces="   "

# gitlab
printf "${GREEN}[GITLAB]${NC} - Install and launch app...\n"
sudo kubectl apply -f ./confs/gitlab/namespace.yaml
sudo kubectl apply -n gitlab -f ./confs/gitlab/volume.yaml > /dev/null
sudo kubectl apply -n gitlab -f ./confs/gitlab/deployment.yaml > /dev/null
sudo kubectl apply -n gitlab -f ./confs/gitlab/service.yaml > /dev/null

# wait gitlab pods running
printf "${GREEN}[GITLAB]${NC} - Waiting for all pods to be running...\n"
while true; do
	running_pods=$(sudo kubectl get pods -n gitlab --field-selector=status.phase=Running 2>/dev/null | grep -c "gitlab")
	if [[ "$running_pods" -eq "1" ]]; then
		printf "\r${YELLOW}[GITLAB]${NC} - Waiting...	(1/1)\n"
		printf "${GREEN}[GITLAB]${NC} - All pods are running.\n"
		break
	else
		for (( i=1; i<=${#dots}; i++ )); do
			printf "\r${YELLOW}[GITLAB]${NC} - Waiting${dots:0:$i}${spaces:($i-1):3}	($running_pods/1)"
			sleep 1
		done
	fi
done

# network settings
sudo kubectl apply -n gitlab -f ./confs/gitlab/ingress.yaml

printf "${GREEN}[GITLAB]${NC} - Waiting for GitLab service to be ready.\n"
response="000"
while [[ "$response" != "302" ]]; do
  response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/gitlab/ || echo "000")
  if [[ "$response" == "302" ]]; then
	printf "\r${YELLOW}[GITLAB]${NC} - Waiting...	(1/1)\n"
    break
  else
    for (( i=1; i<=${#dots}; i++ )); do
		printf "\r${YELLOW}[GITLAB]${NC} - Waiting${dots:0:$i}${spaces:($i-1):3}	(0/1)\n"
		sleep 1
	done
  fi
done

password=$(sudo kubectl exec -n gitlab $(sudo kubectl get pods -n gitlab -l app=gitlab -o jsonpath='{.items[0].metadata.name}') -- cat /etc/gitlab/initial_root_password | awk '/Password:/ {print $2}')
echo "$password" > .gitlab_password

# print informations
echo "gitlab available at: http://localhost/gitlab"
echo "login: admin, password: $password"