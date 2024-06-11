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

# check if all files are present
if [ -f "./confs/argocd/resource.yaml" ] && [ -f "./confs/argocd/ingress.yaml" ] && [ -f "./confs/dev/app.yaml" ] && [ -f "./confs/dev/ingress.yaml" ]; then
	printf "${GREEN}[LINUX]${NC} - All files found.\n"
else
	printf "${RED}[LINUX]${NC} - Script must be launched with Makefile using 'make'. And this is the structure expected:\n"
	printf "IoT.\n"
	printf "├── Makefile\n"
	printf "├── confs\n"
	printf "│   ├── argocd\n"
	printf "│   │   ├── ingress.yaml\n"
	printf "│   │   └── resource.yaml\n"
	printf "│   └── dev\n"
	printf "│       ├── app.yaml\n"
	printf "│       └── ingress.yaml\n"
	printf "└── scripts\n"
	printf "    ├── argocd.sh\n"
	printf "    ├── checks.sh\n"
	printf "    ├── dev.sh\n"
	printf "    ├── k3d.sh\n"
	printf "    └── prerequisities.sh\n"
	exit 1
fi