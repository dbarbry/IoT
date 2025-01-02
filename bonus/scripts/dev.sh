#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# variables
REPO_NAME="jsrassik"
GITHUB_USERNAME="Florian-A"
GITLAB_URL="http://localhost/gitlab/"
GITLAB_ORIGIN_URL="http://localhost/gitlab/root/$REPO_NAME.git"
GITHUB_REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME"
CURRENT_DIR=$(pwd)

# gitlab access token
get_gitlab_access_token() {
    curl_response=$(curl --silent --show-error --request POST \
        --form "grant_type=password" --form "username=root" \
        --form "password=$(cat .gitlab_password)" "$GITLAB_URL/oauth/token")

    access_token=$(echo "$curl_response" | grep -o '"access_token":"[^"]*' | cut -d':' -f2 | tr -d '"')
    echo "$access_token"
}

# gitlab repo
create_gitlab_repo() {
    access_token="$1"
    curl_response=$(curl --silent --show-error --request POST \
        --header "Authorization: Bearer $access_token" --form "name=$REPO_NAME" \
        --form "visibility=public" "$GITLAB_URL/api/v4/projects")
}

# clone github repo
clone_github_repo() {
    rm -rf /tmp/"$REPO_NAME"
    git clone "$GITHUB_REPO_URL" /tmp/"$REPO_NAME"
}

echo -e "${YELLOW}Deploying the static project.${NC}\n"

# using functions
printf "${GREEN}[DEV]${NC} - Clone github repo...\n"
clone_github_repo
access_token=$(get_gitlab_access_token)

printf "${GREEN}[DEV]${NC} - Create gitlab repo...\n"
create_gitlab_repo "$access_token"

# config gitlab
cd /tmp/"$REPO_NAME"
gitlab_repo_url_with_token="http://oauth2:$access_token@localhost/gitlab/root/jsrassik.git"
git remote add gitlab "$gitlab_repo_url_with_token"

# push onto gitlab
printf "${GREEN}[DEV]${NC} - Push local repo into local gitlab...\n"
echo -e "${YELLOW}Pushing to GitLab...${NC}\n"
git push --set-upstream gitlab master
cd "$CURRENT_DIR"

# dev app
printf "${GREEN}[DEV]${NC} - Install and launch app...\n"
sudo kubectl apply -f ./confs/dev/namespace.yaml
sudo kubectl apply -n argocd -f ./confs/dev/app.yaml > /dev/null
sudo kubectl apply -n dev -f ./confs/dev/ingress.yaml > /dev/null
