#!/bin/bash

##########################################
# Requirements: yq gsutil
##########################################
DEPENDENCIES="yq jq gsutil gcloud"
SELFHOSTED_MODE="k8s"
FILE_DIR=""
CARTO_SERVICE_ACCOUNT_FILE="./carto-service-account.json"
CLIENT_STORAGE_BUCKET=""
CUSTOMER_PACKAGE_NAME_PREFIX="carto-selfhosted-${SELFHOSTED_MODE}-customer-package"
CUSTOMER_PACKAGE_FOLDER="customer-package"
##########################################

function check_deps()
{
  for DEP in ${DEPENDENCIES}; do
    # shellcheck disable=SC2261,SC2210
    command -v "${DEP}" 2>&1 > /dev/null || \
      { echo -e "\n[ERROR]: missing dependency <${DEP}>. Please, install it.\n"; exit 1;}
  done
}

function check_input_files()
{
  # =================================
  # $1 -> input file to validate
  # =================================
  if ! [ -e "$1" ]; then
    echo -e "\n[ERROR]: unable to locate <$1>. Please check that the file exists.\n"
    usage
    exit 2
  fi
}

function usage()
{
  cat <<EOF

   Usage: $PROGNAME [--dir] [dir_path] [--selfhosted-mode] [k8s|docker]

   optional arguments:
     -h, --help             Show this help message and exit
     -d, --dir              Folder path where both <carto-values.yaml> and <carto-secrets.yaml> are located (k8s)
                            or where both <customer.env> and <key.json> are located (docker). 
                            Default is current directory.
     -s, --selfhosted-mode  Selfhosted-mode for the customer package: k8s, or docker. Default is k8s.

EOF
}

# ==================================================
# Verify input
# ==================================================
PROGNAME="$(basename "$0")"

# use getopt and store the output into $OPTS
# note the use of -o for the short options, --long for the long name options
# and a : for any option that takes a parameter
OPTS=$(getopt -o "hd:s:" --long "help,dir:,selfhosted-mode:" -n "$PROGNAME" -- "$@")

# Check getopt errors
# shellcheck disable=SC2166,SC2181
if [ $? -ne 0 ] ; then
  echo -e "[ERROR]: please check input arguments."
  usage
  exit 1
elif [ $# -lt 2 -o $# -gt 5 ]; then
  usage
  exit 1
fi

eval set -- "$OPTS"

# Remove trailing slash from --dir argument
while true; do
  case "$1" in
    -h | --help ) usage; exit; ;;
    -d | --dir) FILE_DIR="${2%/}"; shift 2 ;;
    -s | --selfhosted-mode) SELFHOSTED_MODE="$2"; shift 2 ;;
    -- ) shift ;;
    * ) break ;;
  esac
done

# ==================================================
# main block
# ==================================================
# docker
CARTO_ENV="${FILE_DIR}/customer.env"
CARTO_SA="${FILE_DIR}/key.json"
# k8s
CARTO_VALUES="${FILE_DIR}/carto-values.yaml"
CARTO_SECRETS="${FILE_DIR}/carto-secrets.yaml"
# global
CUSTOMER_PACKAGE_NAME_PREFIX="carto-selfhosted-${SELFHOSTED_MODE}-customer-package"

# Check dependencies
check_deps

# Validate selfhosted mode
if [ "$(echo "${SELFHOSTED_MODE}" | grep -E "docker|k8s")" == "" ]; then
  echo -e "\n[ERROR]: available selfhosted modes: k8s or docker\n"
  usage
  exit 1
fi

# Check that required files exist
if [ "${SELFHOSTED_MODE}" = "k8s" ]; then
  check_input_files "${CARTO_VALUES}"
  check_input_files "${CARTO_SECRETS}"
fi
if [ "${SELFHOSTED_MODE}" = "docker" ]; then
  check_input_files "${CARTO_ENV}"
  check_input_files "${CARTO_SA}"
fi

# Get information from YAML files (k8s) or customer.env file (docker)
if [ "${SELFHOSTED_MODE}" = "k8s" ]; then
  yq ".cartoSecrets.defaultGoogleServiceAccount.value" < "${CARTO_SECRETS}" | \
    grep -v "^$" > "${CARTO_SERVICE_ACCOUNT_FILE}"
  CLIENT_STORAGE_BUCKET=$(yq -r ".appConfigValues.workspaceImportsBucket" < "${CARTO_VALUES}")
  TENANT_ID=$(yq -r ".cartoConfigValues.selfHostedTenantId" < "${CARTO_VALUES}")
  CLIENT_ID="${TENANT_ID/#onp-}" # Remove onp- prefix
  SELFHOSTED_VERSION_CURRENT=$(yq -r ".cartoConfigValues.customerPackageVersion" < "${CARTO_VALUES}") 
fi

# shellcheck disable=SC1090
if [ "${SELFHOSTED_MODE}" = "docker" ]; then
  source "${CARTO_ENV}"
  cp "${CARTO_SA}" "${CARTO_SERVICE_ACCOUNT_FILE}"
  CLIENT_STORAGE_BUCKET="${WORKSPACE_IMPORTS_BUCKET}"
  TENANT_ID="${SELFHOSTED_TENANT_ID}"
  CLIENT_ID="${TENANT_ID/#onp-}" # Remove onp- prefix
  SELFHOSTED_VERSION_CURRENT="${CARTO_SELFHOSTED_CUSTOMER_PACKAGE_VERSION}"
fi

# Get information from JSON service account file
CARTO_SERVICE_ACCOUNT_EMAIL=$(jq -r ".client_email" < "${CARTO_SERVICE_ACCOUNT_FILE}")
CARTO_GCP_PROJECT=$(jq -r ".project_id" < "${CARTO_SERVICE_ACCOUNT_FILE}")

# Download the latest customer package
gcloud auth activate-service-account "${CARTO_SERVICE_ACCOUNT_EMAIL}" \
  --key-file="${CARTO_SERVICE_ACCOUNT_FILE}" \
  --project="${CARTO_GCP_PROJECT}"

# Get latest customer package version
CUSTOMER_PACKAGE_FILE_LATEST=$(gsutil ls "gs://${CLIENT_STORAGE_BUCKET}/${CUSTOMER_PACKAGE_FOLDER}/${CUSTOMER_PACKAGE_NAME_PREFIX}-${CLIENT_ID}-*-*-*.zip")
SELFHOSTED_VERSION_LATEST=$(echo "${CUSTOMER_PACKAGE_FILE_LATEST}" | grep -Eo "[0-9]+-[0-9]+-[0-9]+")

# Download package
gsutil cp \
  "gs://${CLIENT_STORAGE_BUCKET}/${CUSTOMER_PACKAGE_FOLDER}/${CUSTOMER_PACKAGE_NAME_PREFIX}-${CLIENT_ID}-${SELFHOSTED_VERSION_LATEST}.zip" .

# Print message
echo -e "\n##############################################################"
echo -e "Current selfhosted version in [carto-values.yaml]: ${SELFHOSTED_VERSION_CURRENT}"
echo -e "Latest selfhosted version downloaded: ${SELFHOSTED_VERSION_LATEST}"
echo -e "Downloaded file: $(basename "${CUSTOMER_PACKAGE_FILE_LATEST}")"
echo -e "Downloaded from: ${CUSTOMER_PACKAGE_FILE_LATEST}"
echo -e "##############################################################\n"
