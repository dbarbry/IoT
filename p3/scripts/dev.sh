#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'


# dev app
printf "${GREEN}[DEV]${NC} - Install and launch app...\n"
kubectl create namespace dev

if [ -f "./confs/dev/app.yaml" ]; then
	sudo kubectl apply -n argocd -f ./confs/dev/app.yaml > /dev/null
else
	printf "${RED}[ARGOCD]${NC} - ./confs/dev/app.yaml not found, but necessary.\n"
	exit 1
fi

if [ -f "./confs/dev/ingress.yaml" ]; then
	sudo kubectl apply -n dev -f ./confs/dev/ingress.yaml > /dev/null
else
	printf "${RED}[ARGOCD]${NC} - ./confs/dev/ingress.yaml not found, but necessary.\n"
	exit 1
fi

