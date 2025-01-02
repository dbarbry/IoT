#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

dots="..."
spaces="   "

# argocd
printf "${GREEN}[ARGOCD]${NC} - Install and launch app...\n"
sudo kubectl apply -f ./confs/argocd/namespace.yaml
sudo kubectl apply -n argocd -f ./confs/argocd/resource.yaml > /dev/null

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
sudo kubectl apply -n argocd -f ./confs/argocd/ingress.yaml

# retrieving password
password=$(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# print informations
printf "${GREEN}[ARGOCD]${NC} - Retrieving credentials...\n"

echo "argocd available at: http://localhost/argocd"
echo "login: admin, password: $password"