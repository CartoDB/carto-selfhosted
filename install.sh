#!/bin/sh

if [ $# -gt 1 ]
then
  echo "[error] too many arguments, only one argument permitted"
  echo "[help] usage: sh install.sh [--ignore-checks][--help]"
  exit 1
fi

if [ $# -eq 1 ] && [ $1 = '--help' ]
then
  echo "[help] usage: sh install.sh [--ignore-checks][--help]"
  exit 0
fi

if [ $# -eq 1 ] && [ $1 = '--ignore-checks' ]
then
  IGNORE_CHECKS=true
else
  IGNORE_CHECKS=false
fi

DOCKER_MINIMUM_VERSION_MAJOR=20
DOCKER_MINIMUM_VERSION_MINOR=10
COMPOSE_MINIMUM_VERSION_MAJOR=1
COMPOSE_MINIMUM_VERSION_MINOR=29

check_docker_version() {
    docker_version_major=$(docker --version | awk  '{ print $3}' | awk -F. '{ print $1 }')
    docker_version_minor=$(docker --version | awk  '{ print $3}' | awk -F. '{ print $2 }')

    if [ $docker_version_major -ge $DOCKER_MINIMUM_VERSION_MAJOR ]
    then
      if [ $docker_version_minor -ge $DOCKER_MINIMUM_VERSION_MINOR ]
      then
        :
      else
        echo "[error] minimum docker version is $DOCKER_MINIMUM_VERSION_MAJOR.$DOCKER_MINIMUM_VERSION_MINOR"
        exit 1
      fi
    else
      echo "[error] minimum docker version is $DOCKER_MINIMUM_VERSION_MAJOR.$DOCKER_MINIMUM_VERSION_MINOR"
      exit 1
    fi
}

check_compose_version() {
    # Docker Compose version v2.1.1
    # docker-compose version 1.29.2, build 5becea4c
    compose_version_extracted=$(docker-compose --version | sed 's/^.*version\ //g' | sed 's/[\,\ ].*$//g' | sed 's/v//g')
    compose_version_major=$(echo "${compose_version_extracted}" | awk -F. '{ print $1 }')
    compose_version_minor=$(echo "${compose_version_extracted}" | awk -F. '{ print $2 }')

    if [ $compose_version_major -ge $COMPOSE_MINIMUM_VERSION_MAJOR ]
    then
      if [ $compose_version_minor -ge $COMPOSE_MINIMUM_VERSION_MINOR ]
      then
        :
      else
        echo "[error] minimum docker-compose version is $COMPOSE_MINIMUM_VERSION_MAJOR.$COMPOSE_MINIMUM_VERSION_MINOR"
        exit 1
      fi
    else
      echo "[error] minimum docker-compose version is $COMPOSE_MINIMUM_VERSION_MAJOR.$COMPOSE_MINIMUM_VERSION_MINOR"
      exit 1
    fi
}

create_env_file() {
    echo "[info] creating .env file..."
    version=$(cat VERSION)
    cat customer.env > .env
    echo "" >> .env
    echo "CARTO_ONPREMISE_VERSION=$version" >> .env
    cat env.tpl >> .env
    mkdir -p certs
    cp key.json certs/key.json
    echo "[info] file .env successfully created"
    echo "[info] script finished, run docker-compose up -d"
}

set -e

if [ $IGNORE_CHECKS = true ]
then
  echo "[info] skipping command checks..."
  create_env_file
  exit 0
fi

echo "[info] running command checks..."
if ! command -v docker > /dev/null 2>&1
then
    echo "[error] docker is not installed, you can use the ./scripts/install_docker.sh helper"
    exit 1
fi

check_docker_version

if ! command -v docker-compose > /dev/null 2>&1
then
    echo "[error] docker-compose is not installed, you can use the ./scripts/install_docker-compose.sh helper"
    exit 1
fi

check_compose_version

if [ ! -f VERSION ]; then
    echo "[error] missing VERSION file"
    exit 1
fi

if [ ! -f customer.env ]; then
    echo "[error] missing customer.env file"
    exit 1
fi

if [ ! -f key.json ]; then
    echo "[error] missing key.json file"
    exit 1
fi

create_env_file
