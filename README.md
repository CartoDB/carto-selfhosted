# CARTO Self Hosted

Deploy CARTO in a self hosted environment. It is provided in two flavours:

- [Kubernetes with helm charts](https://github.com/CartoDB/carto-selfhosted-helm)
- Docker compose for single manchine instalations

## Databases

Both flavours are recomended to be installed using external and managed databases (Postgres and Redis). The versions recommended are:

- Redis +6
- Postgres +11

For development and testing purposues there is an option to use databases inside the deployment. But be aware that no backup, recovery, encryption… is provided.

## Kubernetes

Follow the instrucions from the [helm chart](https://github.com/CartoDB/carto-selfhosted-helm) repository.

## Docker Installation

### Things you will need

1. A Linux machine with internet access (firewall permits outgoing connections, and incoming to port 80 and 443)
    - It should have at least 2 CPUs (x86) and 8 GB of memory (in AWS a `t3.large` or `e2-standard-2` in GCP)
    - 60 GB disk or more
    - Ubuntu 18.04 or above (other Linux versions might work also)
2. A domain/subdomain that will be pointing to the machine
3. A TLS certificate for the domain/subdomain (if not provided a self signed will be generated)
4. Two files received from CARTO (License and configuration)
5. Docker and docker-compose installed (there are two helper scripts in the `scripts` folder)
6. OPTIONAL: Cloud Buckets. CARTO provides them in GCP, but if you want to use your own in your cloud provider check the [Bucket configuration](doc/buckets.md)
7. OPTIONAL BUT RECOMMENDED: External managed Postgres 13 and Redis 5 (eg Memory store or CloudSQL in GCP)

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
      WORKSPACE_POSTGRES_USER=<FILL_ME>
      WORKSPACE_POSTGRES_PASSWORD=<FILL_ME>
      POSTGRES_ADMIN_USER=<FILL_ME>
      POSTGRES_ADMIN_PASSWORD=<FILL_ME>
    ```

    > Note: In case you are using a Postgres hosted on Azure, you should add two additional env vars. When connecting to Azure Postgres the connection user name it's different that the iternal user name, so we need to differentiate between those users, where

    > `WORKSPACE_POSTGRES_INTERNAL_USER` - same value as `WORKSPACE_POSTGRES_USER` but without the `@db-name` prefix

    > `POSTGRES_LOGIN_USER` - same value as `POSTGRES_ADMIN_USER` but without the `@db-name` prefix

    ```bash
      # In case your Postgres it's hosted on Azure you should add 2 additional env vars
      WORKSPACE_POSTGRES_INTERNAL_USER=<FILL_ME>
      POSTGRES_LOGIN_USER=<FILL_ME>
    ```

    - Only for local database (this should be used only in development/testing environments) container: Follow the instructions in the .env file (comment and uncomment the vars as in the example below):

    ```bash
      # Your custom configuration for a external postgres database (comment when local db)
      # LOCAL_POSTGRES_SCALE=0
      # WORKSPACE_POSTGRES_HOST=<FILL_ME>
      # WORKSPACE_POSTGRES_PORT=<FILL_ME>
      # WORKSPACE_POSTGRES_USER=<FILL_ME>
      # WORKSPACE_POSTGRES_PASSWORD=<FILL_ME>
      # POSTGRES_ADMIN_USER=<FILL_ME>
      # POSTGRES_ADMIN_PASSWORD=<FILL_ME>

      # Configuration for using a local postgres, instead of a external one (comment when external db)
      LOCAL_POSTGRES_SCALE=1
      WORKSPACE_POSTGRES_HOST=workspace-postgres
      WORKSPACE_POSTGRES_PORT=5432
      POSTGRES_ADMIN_PASSWORD=someRandomPasswordPrefilled
    ```

    - For managed/external redis: Configure the managed redis to use for workspace by filling these variables:

    ```bash
      # Your custom configuration for a external redis (comment when local redis)
      LOCAL_REDIS_SCALE=0
      REDIS_HOST=<FILL_ME>
      REDIS_PORT=<FILL_ME>
      REDIS_PASSWORD=<FILL_ME>
    ```

    - Only for local redis (this should be used only in development/testing environments) container: Follow the instructions in the .env file (comment and uncomment the vars as in the example below):

    ```bash
    # Your custom configuration for a external redis (comment when local redis)
    # LOCAL_REDIS_SCALE=0
    # REDIS_HOST=<FILL_ME>
    # REDIS_PORT=<FILL_ME>
    # REDIS_PASSWORD=<FILL_ME>

    # Configuration for using a local redis, instead of a external one (comment when external redis)
    LOCAL_REDIS_SCALE=1
    REDIS_HOST=redis
    REDIS_PORT=6379
    ```

    - Configure the domain used. The value `SELFHOSTED_DOMAIN` should be the domain that will point to this installation (by default the domain will be `carto3-onprem.lan` with a self signed certificate)
    - Copy your `.crt` and `.key` files from the TLS certificate in the `certs` folder. In the `customer.env` you should add three new values (changing `<cert>` for the file names you just copied):

    ```bash
      ROUTER_SSL_CERTIFICATE_PATH=/etc/nginx/ssl/<cert>.crt
      ROUTER_SSL_CERTIFICATE_KEY_PATH=/etc/nginx/ssl/<cert>.key
      ROUTER_SSL_AUTOGENERATE=0
    ```

    - If you have a API KEY for Google Maps you can set it on `REACT_APP_GOOGLE_MAPS_API_KEY` (OPTIONAL step)
    - In case you want to use your own cloud buckets, read the information in `customer.env` and uncomment the supported provider (AWS S3, GCP Buckets or Azure Buckets). Fill in the [credentials](doc/buckets.md).

6. Run the installation script `./install.sh`
7. Bring up the environment
    - If you are running with external databases. Run `docker-compose up -d`
    - If you are using local databases:
        - Run first `docker-compose up -d workspace-postgres redis` to start the databases
        - And then `docker-compose up -d`
8. Use your browser and go to the domain you configured. Follow the registration process

### Update

To update you CARTO Self Hosted to the newest version you will need to:

1. Change to the directory where you cloned the repository `cd carto-selfhosted`
2. Update to the latest version `git pull`
3. If you have received a new customer package from CARTO, apply the changes from your `customer.env` to the new `customer.env` (make a backup of your old and working `customer.env`)
4. Run `./install.sh`. If some new configuration is needed the script will inform you
5. Run `docker-compose up -d`
6. If there are open sesions in web browsers they should refresh the page. Otherwise they might get errors
