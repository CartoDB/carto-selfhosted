# Tools

## Download customer package tool

### Purpose

This tool can be used to download a newer version of the Carto selfhosted customer package, allowing customers to update an existing installation to the Carto selfhosted latest release without having to contact support to provide the files.

### Requirements

- Customer package files (`customer.env` and `key.json`) used for the existing installation.
- Linux machine with bash terminal.
- Packages installed: `yq`, `jq` and `gcloud`.

### How to download the latest customer package

1. Run the script passing the following arguments:
   - `-d | --dir` Directory containing the existing `customer.env` and `key.json` files.
   - `-s | --selfhosted-mode` Carto selfhosted installation mode. Use `docker`.

   ```
   $ ./carto-download-customer-package.sh -d /tmp/carto -s docker
   Activated service account credentials for: [serv-onp-xxx@carto-tnt-onp-xxx.iam.gserviceaccount.com]
   Copying gs://carto-tnt-onp-xxx-client-storage/customer-package/carto-selfhosted-docker-customer-package-xxx-2022-10-18.zip...
   / [1 files][  3.5 KiB/  3.5 KiB]                                                
   Operation completed over 1 objects/3.5 KiB.                                      
   ```

2. Unzip your customer package files and use them to update your Carto selfhosted installation.