#!/bin/sh
set -e

COMPOSE_VERSION=2.1.1

command_available() {
  type "$1" >/dev/null 2>&1
}

if ! command_available docker
then
    if ! command_available wget && command_available yum; then
    sudo yum install wget
    fi
    wget -qO- https://get.docker.com/ | sh
    sudo usermod -aG docker $USER
    newgrp docker
fi

if ! command_available docker-compose
then
    sudo -E curl -L "https://github.com/docker/compose/releases/download/v$COMPOSE_VERSION/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

