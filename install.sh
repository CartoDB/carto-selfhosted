#!/bin/sh

./scripts/install_docker.sh

if [ ! -f customer.env ]; then
    echo "Missing customer.env file"
    exit 1
fi

if [ ! -f key.json ]; then
    echo "Missing key.json file"
    exit 1
fi

cat customer.env > .env
cat env.tpl >> .env

mkdir -p certs
cp key.json certs/key.json
