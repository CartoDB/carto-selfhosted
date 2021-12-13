#!/bin/sh

set -e

# ./scripts/install_docker.sh

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

version=`cat VERSION`

cat customer.env > .env
echo "\nCARTO_ONPREMISE_VERSION=$version" >> .env
cat env.tpl >> .env

mkdir -p certs
cp key.json certs/key.json

echo "Ready, run docker-compose up -d"