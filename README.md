# CARTO Self Hosted

Deploy CARTO in a self hosted environment.

## Docker Installation

You need a TODO define reqs

### Steps

1. Login in the machine where the deployment will happen
2. Check out this repo `git clone https://github.com/CartoDB/carto-selfhosted.git`
3. Change to the repo directory `cd carto-selfhosted`
4. You should have received two files from CARTO, please copy them inside this directory
5. Open with an editor the `customer.env` file and:
    - Update the `ONPREM_DOMAIN` with the domain name where this CARTO installation will run under (by default the domain will be `carto3-onprem.lan` with a self signed certificate).
    - TODO add the TLS cert instructions
    - If you have a API KEY for Google Maps you can set it on `REACT_APP_GOOGLE_MAPS_API_KEY` (OPTIONAL step)
6. Run the installation script `./install.sh`
7. Bring up the environment `docker-compose up -d`
    ⚠️ Until the registry is public you need to authenticate to pull images. You need to have the `gcloud` cli installed and run:
    `gcloud auth activate-service-account --key-file=key.json` and then `gcloud auth configure-docker` ⚠️
8. Use your browser and go to the domain you configured. Follow the registration process
