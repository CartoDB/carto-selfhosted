# CARTO Self Hosted

Deploy CARTO in a self hosted environment.

## Docker Installation

### Things you will need

1. A Linux machine with internet access (firewall permits outgoing connections, and incoming to port 80 and 443)
    - It should have at least 2 CPUs (not ARM) and 8 GB of memory (in AWS a `t3.large` or `e2-standard-2` in GCP)
    - 50 GB disk or more
    - Ubuntu 18.04 or above (other Linux versions might work also)
2. A domain/subdomain that will be pointing to the machine
3. A TLS certificate for the domain/subdomain (if not provided a self signed will be generated)
4. Two files received from CARTO (License and configuration)
5. Docker and docker-compose installed (there are two helper scripts in the `scripts` folder)
6. OPTIONAL: Cloud Buckets. CARTO provides them in GCP, but if you want to use your own in your cloud provider check the [Bucket configuration](doc/buckets.md)

### Steps

1. Login in the machine where the deployment will happen
2. Clone this git repository: `git clone https://github.com/CartoDB/carto-selfhosted.git`
3. Change to the directory where you cloned the repository `cd carto-selfhosted`
4. You should have received two files from CARTO (`customer.env`, `key.json`), please copy them inside this directory
5. Open with an editor the `customer.env` file and:
    - For managed/external database: Configure the managed postgres database to use for workspace by filling these variables:

    ```bash
      # Your custom configuration for a external postgres database (comment when local db)
      LOCAL_POSTGRES_SCALE=0
      WORKSPACE_POSTGRES_HOST=<FILL_ME>
      WORKSPACE_POSTGRES_PORT=<FILL_ME>
      POSTGRES_PASSWORD=<FILL_ME>
    ```

    - Only for local database (this should be used only in development/testing environments) container: Follow the instructions in the .env file (comment and uncomment the vars as in the example below):

    ```bash
      # Your custom configuration for a external postgres database (comment when local db)
      # LOCAL_POSTGRES_SCALE=0
      # WORKSPACE_POSTGRES_HOST=<FILL_ME>
      # WORKSPACE_POSTGRES_PORT=<FILL_ME>
      # POSTGRES_PASSWORD=<FILL_ME>

      # Configuration for using a local postgres, instead of a external one (comment when external db)
      # You also have to uncomment the POSTGRES_PASSWORD variable generated in the customer package
      LOCAL_POSTGRES_SCALE=1
      WORKSPACE_POSTGRES_HOST=workspace-postgres
      WORKSPACE_POSTGRES_PORT=5432
    ```

    - Configure the domain used. The value `SELFHOSTED_DOMAIN` should be the domain that will point to this installation (by default the domain will be `carto3-onprem.lan` with a self signed certificate)
    - Copy your `.crt` and `.key` files from the TLS certificate in the `certs` folder. In the `customer.env` you should add three new values (changing `<cert>` for the file names you just copied):

    ```bash
      ROUTER_SSL_CERTIFICATE_PATH=/etc/nginx/ssl/<cert>.crt
      ROUTER_SSL_CERTIFICATE_KEY_PATH=/etc/nginx/ssl/<cert>.key
      ROUTER_SSL_AUTOGENERATE=0
    ```

    - If you have a API KEY for Google Maps you can set it on `REACT_APP_GOOGLE_MAPS_API_KEY` (OPTIONAL step)

6. Run the installation script `./install.sh`
7. Bring up the environment `docker-compose up -d`
8. Use your browser and go to the domain you configured. Follow the registration process

### Update

To update you CARTO Self Hosted to the newest version you will need to:

1. Change to the directory where you cloned the repository `cd carto-selfhosted`
2. Update to the latest version `git pull`
3. Run `./install.sh`. If some new configuration is needed the script will inform you
4. Run `docker-compose up -d`
5. If there are open sesions in web browsers they should refresh the page. Otherwise they might get errors
