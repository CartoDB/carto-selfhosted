# Tools

## Download customer package tool

### Description

This tool can be used to download a newer version of the Carto selfhosted customer package, allowing customers to update an existing installation to the Carto selfhosted latest release without having to contact support to provide the files.

### Pre-requisites

- Customer package files (`customer.env` and `key.json`) used for the existing installation.
- Linux machine with bash terminal.
- Packages installed: `yq`, `jq` and `gcloud`.

### How to download the latest customer package

1. Run the script passing the following arguments:

> | flag | description |
> |:----:|:------------|
> | `-d` | Directory containing the existing `customer.env` and `key.json` files. |
> | `-s` | Carto selfhosted installation mode. Use `docker`. |

> ```bash
> $ ./carto-download-customer-package.sh -d /tmp/carto -s docker
> ```

> Example output:
>
> ```console
> ℹ️ selfhosted mode: docker
> ✅ found: /tmp/carto/carto-values.yaml
> ✅ found: /tmp/carto/carto-secrets.yaml
> ✅ activating: service account credentials for: [serv-onp-xxx@carto-tnt-onp-xxx.iam.gserviceaccount.com]
> Copying gs://carto-tnt-onp-xxx-client-storage/customer-package/carto-selfhosted-docker-customer-package-xxx-2023-6-16.zip...
> / [1 files][  2.6 KiB/  2.6 KiB]
> Operation completed over 1 objects/2.6 KiB.
> ✅ downloading: carto-selfhosted-docker-customer-package-xxx-2023-6-16.zip
>
> ##############################################################
> Current selfhosted version in [carto-values.yaml]: 2023.6.16
> Latest selfhosted version downloaded: 2023-6-16
> Downloaded file: carto-selfhosted-docker-customer-package-xxx-2023-6-16.zip
> Downloaded from: gs://carto-tnt-onp-xxx-client-storage/customer-package/carto-selfhosted-docker-customer-package-xxx-2023-6-16.zip
> ##############################################################
>
> ✅ finished [0]
> ```

2. Unzip your customer package files and use them to update your Carto selfhosted installation.
