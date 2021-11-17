# CARTO Self Hosted

Deploy CARTO in a self hosted environment.

## Docker Installation

You need a TODO define reqs

### Steps

1. Login in the machine where the deployment will happen
2. Check out this repo `git clone https://github.com/CartoDB/carto-selfhosted.git`
3. Change to the repo directory `cd carto-selfhosted`
4. You should have received two files from CARTO, please place them inside this directory
5. Open with an editor the `.env` file and:
    - Update the version `CARTO_ONPREMISE_VERSION` to the latest version TODO this should be automatic
    - Update the `ONPREM_DOMAIN` with the domain where this installation will run
    - TODO add the TLS cert
    - If you have a API KEY for Google Maps you can set it on `REACT_APP_GOOGLE_MAPS_API_KEY`
6. Run the installation script `./install.sh`
7. Bring up the environment `docker-compose up -d`
8. Use your browser and go to the domain you configured. Follow the registration process
