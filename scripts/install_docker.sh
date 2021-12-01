#!/bin/sh
set -e

COMPOSE_RELEASE=v2.1.1
# Check https://github.com/docker/compose/releases for releases

command_available() {
  type "$1" >/dev/null 2>&1
}

if ! command_available docker
then
    curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
fi

if ! command_available docker-compose
then
    sudo -E curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_RELEASE/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi
