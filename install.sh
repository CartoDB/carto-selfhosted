#!/bin/sh


DOCKER_MINIMUM_VERSION_MAJOR=20
DOCKER_MINIMUM_VERSION_MINOR=10
COMPOSE_MINIMUM_VERSION_MAJOR=2
COMPOSE_MINIMUM_VERSION_MINOR=1

check_docker_version() {
    docker_version_major=$(docker --version | awk  '{ print $3}' | awk -F. '{ print $1 }')
    docker_version_minor=$(docker --version | awk  '{ print $3}' | awk -F. '{ print $2 }')

    if [ $docker_version_major -ge $DOCKER_MINIMUM_VERSION_MAJOR ]
    then
      if [ $docker_version_minor -ge $DOCKER_MINIMUM_VERSION_MINOR ]
      then
        :
      else
        echo "minimum docker version is $DOCKER_MINIMUM_VERSION_MAJOR.$DOCKER_MINIMUM_VERSION_MINOR"
        exit 1
      fi
    else
      echo "minimum docker version is $DOCKER_MINIMUM_VERSION_MAJOR.$DOCKER_MINIMUM_VERSION_MINOR"
      exit 1
    fi
}

check_compose_version() {
    # Docker Compose version v2.1.1
    # docker-compose version 1.29.2, build unknown
    compose_version_extracted=$(docker-compose --version | sed 's/^.*version\ //g' | sed 's/[\,\ ].*$//g' | sed 's/v//g')
    compose_version_major=$(echo "${compose_version_extracted}" | awk '{ print $4}' | awk -F. '{ print $1 }')
    compose_version_minor=$(echo "${compose_version_extracted}" | awk '{ print $4}' | awk -F. '{ print $2 }')

    if [ $compose_version_major -ge $COMPOSE_MINIMUM_VERSION_MAJOR ]
    then
      if [ $compose_version_minor -ge $COMPOSE_MINIMUM_VERSION_MINOR ]
      then
        :
      else
        echo "minimum docker-compose version is $COMPOSE_MINIMUM_VERSION_MAJOR.$COMPOSE_MINIMUM_VERSION_MINOR"
        exit 1
      fi
    else
      echo "minimum docker-compose version is $COMPOSE_MINIMUM_VERSION_MAJOR.$COMPOSE_MINIMUM_VERSION_MINOR"
      exit 1
    fi
}

set -e

if ! command -v docker > /dev/null 2>&1
then
    echo "docker is not installed, you can use the ./scripts/install_docker.sh helper"
    exit 1
fi

check_docker_version

if ! command -v docker-compose > /dev/null 2>&1
then
    echo "docker-compose is not installed, you can use the ./scripts/install_docker-compose.sh helper"
    exit 1
fi

check_compose_version



if [ ! -f VERSION ]; then
    echo "Missing VERSION file"
    exit 1
fi

if [ ! -f customer.env ]; then
    echo "Missing customer.env file"
    exit 1
fi

if [ ! -f key.json ]; then
    echo "Missing key.json file"
    exit 1
fi

version=$(cat VERSION)

cat customer.env > .env
echo "" >> .env
echo "CARTO_ONPREMISE_VERSION=$version" >> .env
cat env.tpl >> .env

mkdir -p certs
cp key.json certs/key.json

echo "Ready, run docker-compose up -d"
