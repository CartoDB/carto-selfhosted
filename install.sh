#!/usr/bin/env bash

#  CARTO 3 Self hosted installer
#
# Usage:
#   install.sh <options>...
#
# Depends on:
# sed
# Github repo https://github.com/CartoDB/carto-selfhosted
#

###############################################################################
# Strict Mode
###############################################################################

# Treat unset variables and parameters other than the special parameters ‘@’ or
# ‘*’ as an error when performing parameter expansion. An 'unbound variable'
# error message will be written to the standard error, and a non-interactive
# shell will exit.
#
# This requires using parameter expansion to test for unset variables.
#
# http://www.gnu.org/software/bash/manual/bashref.html#Shell-Parameter-Expansion
# Short form: set -u
set -o nounset

# Exit immediately if a pipeline returns non-zero.
#
# NOTE: This can cause unexpected behavior. When using `read -rd ''` with a
# heredoc, the exit status is non-zero, even though there isn't an error, and
# this setting then causes the script to exit. `read -rd ''` is synonymous with
# `read -d $'\0'`, which means `read` until it finds a `NUL` byte, but it
# reaches the end of the heredoc without finding one and exits with status `1`.
#
# More information:
#
# https://www.mail-archive.com/bug-bash@gnu.org/msg12170.html
#
# Short form: set -e
set -o errexit

# Print a helpful message if a pipeline with non-zero exit code causes the
# script to exit as described above.
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR

# Allow the above trap be inherited by all functions in the script.
#
# Short form: set -E
set -o errtrace

# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.
set -o pipefail

# Set $IFS to only newline and tab.
#
# http://www.dwheeler.com/essays/filenames-in-shell.html
IFS=$'\n\t'

###############################################################################
# Environment
###############################################################################

# $_ME
#
# This program's basename.
_ME="$(basename "${0}")"
_DOCKER_MINIMUM_VERSION_MAJOR=20
_DOCKER_MINIMUM_VERSION_MINOR=10
_COMPOSE_MINIMUM_VERSION_MAJOR=1
_COMPOSE_MINIMUM_VERSION_MINOR=29

###############################################################################
# Help
###############################################################################

# _print_help()
#
# Usage:
#   _print_help
#
# Print the program help information.
_print_help() {
  cat <<HEREDOC

install.sh prepares your environment to run the docker-compose flavor of Carto Self Hosted
Usage:
  ${_ME} [--ignore-checks]
  ${_ME} --help
Options:
  --help  Show this screen.
HEREDOC
}

###############################################################################
# Program Functions
###############################################################################

_valid_version() {
  local _req_major
  local _req_minor
  local _check_major
  local _check_minor

  _req_major=$1
  _req_minor=$2
  _check_major=$3
  _check_minor=$4

  if [ "${_check_major}" -gt "${_req_major}" ]; then
    true
    return
  else
    if [ "${_check_major}" -lt "${_req_major}" ]; then
      false
      return
    fi
    if [ "${_check_minor}" -ge "${_req_minor}" ]; then
      true
      return
    else
      false
      return
    fi
  fi
}

_check_docker_version() {
  local docker_version_major
  local docker_version_minor
  docker_version_major=$(docker --version | awk '{ print $3}' | awk -F. '{ print $1 }')
  docker_version_minor=$(docker --version | awk '{ print $3}' | awk -F. '{ print $2 }')

  if ! _valid_version ${_DOCKER_MINIMUM_VERSION_MAJOR} ${_DOCKER_MINIMUM_VERSION_MINOR} "${docker_version_major}" "${docker_version_minor}"; then
    _err "Minimum docker version is ${_DOCKER_MINIMUM_VERSION_MAJOR}.${_DOCKER_MINIMUM_VERSION_MINOR}"
    exit 1
  fi
}

_check_compose_version() {
  # Docker Compose version v2.1.1
  # docker-compose version 1.29.2, build 5becea4c
  local compose_version_extracted
  local compose_version_major
  local compose_version_minor

  compose_version_extracted=$(docker-compose --version | sed 's/^.*version\ //g' | sed 's/[\,\ ].*$//g' | sed 's/v//g')
  compose_version_major=$(echo "${compose_version_extracted}" | awk -F. '{ print $1 }')
  compose_version_minor=$(echo "${compose_version_extracted}" | awk -F. '{ print $2 }')

  if ! _valid_version ${_COMPOSE_MINIMUM_VERSION_MAJOR} ${_COMPOSE_MINIMUM_VERSION_MINOR} "${compose_version_major}" "${compose_version_minor}"; then
    _err "Minimum docker-compose version is ${_COMPOSE_MINIMUM_VERSION_MAJOR}.${_COMPOSE_MINIMUM_VERSION_MINOR}"
    exit 1
  fi
}

_migrate_postgres_version_var() {
  sed -i -e 's/POSTGRES_PASSWORD/POSTGRES_ADMIN_PASSWORD/g' customer.env
}

_create_env_file() {
  _migrate_postgres_version_var
  _info "Creating .env file..."
  local version
  version=$(cat VERSION)
  {
    cat customer.env
    echo ""
    echo "CARTO_SELFHOSTED_VERSION=${version}"
    cat env.tpl
  } >.env
  mkdir -p certs
  cp key.json certs/key.json
  _info "File .env successfully created"
  _info "Script finished, run docker-compose up -d"
}


# Description Private function to check versions.
# Not thread-safe.
#
# Example
#    echo "test: $(_check_min_cloud_version 1.2 1.3)"
#
#
# arg $1 string version A
# arg $2 string version B
#
# It orders asc version A and version b and if the first in the list is
# version A returns true, else return false
#
_check_min_cloud_version() {
  local MINIMAL_VERSION
  local PACKAGE_VERSION
  MINIMAL_VERSION=$1
  PACKAGE_VERSION=$2

  if [[ "$(echo "$MINIMAL_VERSION $PACKAGE_VERSION" | tr ' ' '\n' | sort -V | head -n1)" == $MINIMAL_VERSION ]]; then
    cat <<-EOF
      [error] minimum cloud version version is $MINIMAL_VERSION but your package was generated with $PACKAGE_VERSION
      Contact with support for futher assistance.
EOF
    false
  else
    true
  fi

}

function _run_checks() {
  _info "Running command checks..."
  #Docker
  if ! command -v docker >/dev/null 2>&1; then
    _err "docker is not installed, you can use the ./scripts/install_docker.sh helper"
    exit 1
  fi
  _check_docker_version

  #Docker Compose
  if ! command -v docker-compose >/dev/null 2>&1; then
    _err "docker-compose is not installed, you can use the ./scripts/install_docker-compose.sh helper"
    exit 1
  fi
  _check_compose_version

  # Files
  local needed_files
  needed_files=("VERSION" "customer.env" "key.json")
  for file in ${needed_files[*]}; do

  if [ ! -f ${file} ]; then
    _err "Missing ${file} file"
    exit 1
  fi
done

}

function _run_post_checks(){
  if [ -f .env ]; then
    (
      # needed to remove the comments inside the .env
      for line in $(cat .env | sed 's/#.*//g'); do
        export $line
      done
      if [[ "$LOCAL_POSTGRES_SCALE" = "1" ]]; then
        _warn "Using embedded databases is not for PRODUCTION use"
      fi
      if [[ -z "${POSTGRES_ADMIN_PASSWORD}" ]]; then
        _err " There is no Postgres Admin password defined"
      fi
      if _check_min_cloud_version $CARTO_SELFHOSTED_VERSION $CARTO_SELFHOSTED_CUSTOMER_PACKAGE_VERSION = false ; then
        _err "Customer Package outdated, please contact our Support team at support@carto.com"
      fi
    )
  fi
}

## Log functions to avoid "echo" without context and keep style

function _info() {
  printf "[INFO]: %s\n" $1
}

function _warn() {
  printf "[WARN]: %s\n" $1
}

function _err() {
  printf "[ERROR]: %s\n" $1
}

###############################################################################
# Main
###############################################################################

# _main()
#
# Usage:
#   _main [<options>] [<arguments>]
#
# Description:
#   Entry point for the program, handling basic option parsing and dispatching.
_main() {

  #Start argument parsing
  # Avoid complex option parsing when only one program option is expected.
  if [[ $# -gt 1 ]]; then
    _err "too many arguments, only one argument permitted"
    _print_help
    exit 1
  elif [[ "${1:-}" =~ ^--ignore-checks$ ]]; then
    local _IGNORE_CHECKS=true
  elif [[ "${1:-}" =~ ^--help$ ]]; then
    _print_help
    exit 0
  elif [[ $# -eq 1 ]]; then
    _err "invalid argument"
    _print_help
    exit 1
  else
    local _IGNORE_CHECKS=false
  fi
  #End Argument parsing

  if [ ${_IGNORE_CHECKS} = true ]; then
    _info "Skipping command checks..."
    _create_env_file
    exit 0
  else
    _run_checks
    _create_env_file
  fi
    _run_post_checks
  
}

# Call `_main` after everything has been defined.
_main "$@"
