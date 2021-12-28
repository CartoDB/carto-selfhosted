#!/bin/sh
set -e

command_available() {
  type "$1" >/dev/null 2>&1
}

if ! command_available docker
then
  curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
fi


