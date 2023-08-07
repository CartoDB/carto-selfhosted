#!/bin/bash

##########################################
# Requirements: yq jq gsutil gcloud
##########################################
DEPENDENCIES="yq jq gsutil gcloud"
SELFHOSTED_MODE="k8s"
FILE_DIR="."
CARTO_SERVICE_ACCOUNT_FILE="./carto-service-account.json"
CLIENT_STORAGE_BUCKET=""
CUSTOMER_PACKAGE_NAME_PREFIX="carto-selfhosted-${SELFHOSTED_MODE}-customer-package"
CUSTOMER_PACKAGE_FOLDER="customer-package"
##########################################

function _check_deps()
{
  for DEP in ${DEPENDENCIES} ; do
    if ( ! command -v "${DEP}" &>/dev/null ) ; then
      _error "missing dependency <${DEP}>. Please, install it.\n"
    fi
  done
}

function _check_input_files()
{
  # =================================
  # # ARGV1 = input file to validate
  # =================================
  # check if the file exists
  if [ -e "${1}" ] ; then
    _success "found: ${1}"
  else
    _error "unable to locate <${1}>. Please check that the file exists.\n" 3
  fi
  # check if the file size is greater than zero
  [ ! -s "${1}" ] && _error "file <${1}> is empty.\n" 4
}

function _usage()
{
  cat <<EOF

   Usage: $PROGNAME [-d dir_path] [-s <k8s|docker>]

   optional arguments:
     -d    Folder path where both <carto-values.yaml> and <carto-secrets.yaml> are located (k8s)
           or where both <customer.env> and <key.json> are located (docker). 
           Default is current directory.
     -h    Show this help message and exit
     -s    Selfhosted-mode for the customer package: k8s or docker.
           Default is k8s.

EOF
}

function _info() {
  # ARGV1 = message
  echo -e "ℹ️  ${1}"
}

function _success() {
  # ARGV1 = message
  echo -e "✅ ${1}"
}

function _error() {
  # ARGV1 = message
  # ARGV2 = arbitrary error code (default is 1)
  local EXIT_CODE="${2:-1}"
  RED="\033[1;31m"
  YELLOW="\033[1;93m"
  NONE="\033[0m"
  echo -e "❌ ${RED}ERROR ${NONE}[${EXIT_CODE}]: ${YELLOW}${1}${NONE}"
  _usage
  exit "${EXIT_CODE}"
}

# ==================================================
# Verify input
# ==================================================
PROGNAME="$(basename "$0")"

# use getopts builtin to store provided options
while getopts d:s:h OPTS ; do
  case "${OPTS}" in
    d) FILE_DIR="${OPTARG%/}" ;;
    s) SELFHOSTED_MODE="${OPTARG}" ;;
    h) _usage ; exit ;;
    *) _error "Invalid args provided" 1
  esac
done

# ==================================================
# sanity checks
# ==================================================

# Validate provided path
[ ! -d "${FILE_DIR}" ] && _error "Directory <${FILE_DIR}> does not exist."

# Validate selfhosted mode
# shellcheck disable=SC2076
[[ ! '[ "docker", "k8s" ]' =~ "\"${SELFHOSTED_MODE}\"" ]] && _error "illegal value '${SELFHOSTED_MODE}'" 2

# Check dependencies
_check_deps

# ==================================================
# main block
# ==================================================

_info "selfhosted mode: ${SELFHOSTED_MODE}"

# global
CUSTOMER_PACKAGE_NAME_PREFIX="carto-selfhosted-${SELFHOSTED_MODE}-customer-package"
CARTO_ENV="${FILE_DIR}/customer.env"
CARTO_SA="${FILE_DIR}/key.json"

if [ "${SELFHOSTED_MODE}" == "docker" ] ; then
  ENV_SOURCE="$(basename "${CARTO_ENV}")"
  # Check that required files exist
  _check_input_files "${CARTO_SA}"
  _check_input_files "${CARTO_ENV}"
  # Get information from customer.env file
  # shellcheck disable=SC1090
  source "${CARTO_ENV}"
  cp "${CARTO_SA}" "${CARTO_SERVICE_ACCOUNT_FILE}"
  TENANT_ID="${SELFHOSTED_TENANT_ID}"
  CLIENT_ID="${TENANT_ID/#onp-}" # Remove onp- prefix
  SELFHOSTED_VERSION_CURRENT="${CARTO_SELFHOSTED_CUSTOMER_PACKAGE_VERSION}"
  GCP_PROJECT_ID="${SELFHOSTED_GCP_PROJECT_ID}"
elif [ "${SELFHOSTED_MODE}" == "k8s" ] ; then
  # Check that required files exist
  CARTO_VALUES="${FILE_DIR}/carto-values.yaml"
  CARTO_SECRETS="${FILE_DIR}/carto-secrets.yaml"
  ENV_SOURCE="$(basename "${CARTO_VALUES}")"
  _check_input_files "${CARTO_VALUES}"
  _check_input_files "${CARTO_SECRETS}"
  # Get information from YAML files (k8s)
  yq ".cartoSecrets.defaultGoogleServiceAccount.value" < "${CARTO_SECRETS}" | \
    grep -v "^$" > "${CARTO_SERVICE_ACCOUNT_FILE}"
  TENANT_ID="$(yq -r ".cartoConfigValues.selfHostedTenantId" < "${CARTO_VALUES}")"
  CLIENT_ID="${TENANT_ID/#onp-}" # Remove onp- prefix
  SELFHOSTED_VERSION_CURRENT="$(yq -r ".cartoConfigValues.customerPackageVersion" < "${CARTO_VALUES}")"
  GCP_PROJECT_ID="$(yq -r ".cartoConfigValues.selfHostedGcpProjectId" < "${CARTO_VALUES}")"
fi

# Get information from JSON service account file
CARTO_SERVICE_ACCOUNT_EMAIL="$(jq -r ".client_email" < "${CARTO_SERVICE_ACCOUNT_FILE}")"

# Use carto project GCP bucket for custoemr package
CLIENT_STORAGE_BUCKET="${GCP_PROJECT_ID}-client-storage"

# Download the latest customer package
STEP="activating: service account credentials for: [${CARTO_SERVICE_ACCOUNT_EMAIL}]"
if ( gcloud auth activate-service-account "${CARTO_SERVICE_ACCOUNT_EMAIL}" --key-file="${CARTO_SERVICE_ACCOUNT_FILE}" --project="${GCP_PROJECT_ID}" &>/dev/null ) ; then
  _success "${STEP}" ; else _error "${STEP}" 5
fi

# Get latest customer package version
CUSTOMER_PACKAGE_FILE_LATEST="$(gsutil ls "gs://${CLIENT_STORAGE_BUCKET}/${CUSTOMER_PACKAGE_FOLDER}/${CUSTOMER_PACKAGE_NAME_PREFIX}-${CLIENT_ID}-*-*-*.zip")"
SELFHOSTED_VERSION_LATEST="$(echo "${CUSTOMER_PACKAGE_FILE_LATEST}" | grep -Eo "${CLIENT_ID}-[0-9]+-[0-9]+-[0-9]+")"
SELFHOSTED_VERSION_LATEST="${SELFHOSTED_VERSION_LATEST/#${CLIENT_ID}-}"

# Double-check customer package download URI
[[ "${CUSTOMER_PACKAGE_FILE_LATEST}" != "gs://${CLIENT_STORAGE_BUCKET}/${CUSTOMER_PACKAGE_FOLDER}/${CUSTOMER_PACKAGE_NAME_PREFIX}-${CLIENT_ID}-${SELFHOSTED_VERSION_LATEST}.zip" ]] && \
  _error "customer package download URI mismatch" 7

# Download package
STEP="downloading: $(basename "${CUSTOMER_PACKAGE_FILE_LATEST}")"
if ( gsutil cp "${CUSTOMER_PACKAGE_FILE_LATEST}" ./ ) ; then
  _success "${STEP}" && RC="0" ; else _error "${STEP}" 6
fi

# Print message
echo -e "\n##############################################################"
echo -e "Current selfhosted version in [${ENV_SOURCE}]: ${SELFHOSTED_VERSION_CURRENT}"
echo -e "Latest selfhosted version downloaded: ${SELFHOSTED_VERSION_LATEST}"
echo -e "Downloaded file: $(basename "${CUSTOMER_PACKAGE_FILE_LATEST}")"
echo -e "Downloaded from: ${CUSTOMER_PACKAGE_FILE_LATEST}"
echo -e "##############################################################\n"

_success "finished [${RC}]\n"
