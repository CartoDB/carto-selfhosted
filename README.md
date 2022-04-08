# CARTO Self Hosted

Deploy CARTO in a Self Hosted environment. It is provided in two flavours:

- [Kubernetes with helm charts](https://github.com/CartoDB/carto-selfhosted-helm)
- Docker compose for single machine installations

To be able to use CARTO Self Hosted you need to [contact CARTO](https://carto.com/request-live-demo/) and sign up for a CARTO License.

## Databases

Both flavours are recommended to be installed using external and managed databases (Postgres and Redis). The versions recommended are:

- Redis +6
- Postgres +11

For development and testing purposes there is an option to use databases inside the deployment. But be aware that no backup, recovery, encryption… is provided.

## Kubernetes

Follow the instructions from the [helm chart](https://github.com/CartoDB/carto-selfhosted-helm) repository.

## Docker Installation

### Things you will need

1. A Linux machine with internet access (firewall permits outgoing connections, and incoming to port 80 and 443)
    - It should have at least 2 CPUs (x86) and 8 GB of memory (in AWS a `t3.large` or `e2-standard-2` in GCP)
    - 60 GB disk or more
    - Ubuntu 18.04 or above (other Linux versions might work also)
2. A domain/subdomain that will be pointing to the machine
3. A TLS certificate for the domain/subdomain (if not provided a self signed will be generated)
4. *Two files received from CARTO* (License and configuration)
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
      WORKSPACE_POSTGRES_USER=workspace_admin
      WORKSPACE_POSTGRES_PASSWORD=<FILL_ME>
      WORKSPACE_POSTGRES_DB=workspace
      POSTGRES_ADMIN_USER=<FILL_ME>
      POSTGRES_ADMIN_PASSWORD=<FILL_ME>
    ```

    > Note: In case you are using a Postgres hosted on Azure, you should add two additional env vars. When connecting to Azure Postgres the connection user name it's different that the internal user name, so we need to differentiate between those users, where

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
      # WORKSPACE_POSTGRES_USER=workspace_admin
      # WORKSPACE_POSTGRES_PASSWORD=<FILL_ME>
      # WORKSPACE_POSTGRES_DB=workspace
      # POSTGRES_ADMIN_USER=<FILL_ME>
      # POSTGRES_ADMIN_PASSWORD=<FILL_ME>

      # Configuration for using a local postgres, instead of a external one (comment when external db)
      LOCAL_POSTGRES_SCALE=1
      WORKSPACE_POSTGRES_HOST=workspace-postgres
      WORKSPACE_POSTGRES_PORT=5432
      WORKSPACE_POSTGRES_USER=workspace_admin
      WORKSPACE_POSTGRES_PASSWORD=someRandomPasswordPrefilled
      WORKSPACE_POSTGRES_DB=workspace
      POSTGRES_ADMIN_USER=postgres
      POSTGRES_ADMIN_PASSWORD=someRandomPasswordPrefilled
    ```

    - For managed/external redis: Configure the managed redis to use for workspace by filling these variables:

    > :warning: In case you are using a Redis TLS with a self-signed certificate you should add an extra env var named `REDIS_TLS_CA` which value it's the CA cert of the self-signed certificate in plain text

    ```bash
      # Your custom configuration for a external redis (comment when local redis)
      LOCAL_REDIS_SCALE=0
      REDIS_HOST=<FILL_ME>
      REDIS_PORT=<FILL_ME>
      REDIS_PASSWORD=<FILL_ME>
      REDIS_TLS_ENABLED=true
      # Only applies if Redis TLS certificate it's self signed
      # REDIS_TLS_CA=<FILL_ME>
    ```

    - Only for local redis (this should be used only in development/testing environments) container: Follow the instructions in the .env file (comment and uncomment the vars as in the example below):

    ```bash
    # Your custom configuration for a external redis (comment when local redis)
    # LOCAL_REDIS_SCALE=0
    # REDIS_HOST=<FILL_ME>
    # REDIS_PORT=<FILL_ME>
    # REDIS_PASSWORD=<FILL_ME>
    # REDIS_TLS_ENABLED=true

    # Configuration for using a local redis, instead of a external one (comment when external redis)
    LOCAL_REDIS_SCALE=1
    REDIS_HOST=redis
    REDIS_PORT=6379
    REDIS_TLS_ENABLED=false
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
6. If there are open sessions in web browsers they should refresh the page. Otherwise they might get errors

### Migrate from Docker Compose deployment to Kubernetes

To migrate your CARTO Self Hosted from Docker Compose deployment to
[Kubernetes / Helm](https://github.com/CartoDB/carto-selfhosted-helm) you need to follow this generic steps:

⚠️ Migration incurs in downtime. To minimize it, reduce the DNS TTL before starting the process

- Preconditions:
  - You have a running Self Hosted deployed with Docker Compose i.e using a Google Compute engine instance.
  - You have configured external databases (Redis and PostgreSQL)
  - You have a K8s cluster to deploy the new self hosted and credentials to deploy
  - You have received a new customer package from CARTO with carto-values.yaml and carto-secrets.yaml files

- Steps to migrate
   1. Allow network connectivity from k8s nodes to your pre-existing databases. [i.e (Cloud SQL connection notes](https://github.com/CartoDB/carto-selfhosted/README.md#cloud-sql-connection-configuration))
   2. Create a `customizations.yaml` following [this instructions](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations). Keep the same external database connection settings you are using in CARTO for Docker. [Postgres](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-postgres) and [Redis](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-redis).

> ⚠️ NOTE: Do not trust the default values and fill all variables related to database connections, example:

```yaml
externalPostgresql:
  host: "<yourPostgresqlHost"
  adminUser: postgres
  adminPassword: <adminPassword>
  password: <userPassword>
  database: workspace
  user: workspace_admin 
internalPostgresql:
  enabled: false

internalRedis:
  # Disable the internal Redis
  enabled: false
externalRedis:
  host: "yourRedisHost"
  port: "6379"
  password: <AUTH string>"
  tlsEnabled: false
```

> Read also the instructions on how to [expose the Kubernetes](https://github.com/CartoDB/carto-selfhosted-helm/blob/main/customizations/README.md#access-to-carto-from-outside-the-cluster) installation to outside the cluster.

   2. Create a `customizations.yaml` following [these instructions](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations). Keep the same external database connection settings you are using in CARTO for Docker. [Postgres](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-postgres) and [Redis](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-redis).

   3. Shut down you CARTO for Docker deployment: `docker-compose down` ⚠️ From this point, the service is down.
   4. Deploy to your cluster. Follow the [installation steps](https://github.com/CartoDB/carto-selfhosted-helm#installation)
   5. Check pods are running and stable with `kubectl get pods <-n your_namespace>`
   6. Change DNS records to point to the new service (`helm install` will point how to get the IP or DNS), it will take some time to propagate.
   7. Test your CARTO Self Hosted for Kubernetes installation. Service is restored.

If for whatever reason the installation did not go as planned. You can bring back the docker installation and point back your DNS to it.

#### Cloud SQL Connection configuration

If you are connecting with public or private ip to a Google Cloud SQL in your self hosted, you need to add to the instance configuration external static (for public) or internal static IPs ranges as Authorized networks. If you have the resource terraformed you can add the networks with this way (take as a guide):

```hcl
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

locals {
  onprem = ["192.168.1.2", "192.168.2.3"]
}

resource "google_sql_database_instance" "postgres" {
  name             = "postgres-instance-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_11"

  settings {
    tier = "db-f1-micro"

    ip_configuration {

      dynamic "authorized_networks" {
        for_each = local.onprem
        iterator = onprem

        content {
          name  = "onprem-${onprem.key}"
          value = onprem.value
        }
      }
    }
  }
}
```

Or in the web console:

<img width="605" alt="Captura de pantalla 2022-04-05 a las 11 11 11" src="https://user-images.githubusercontent.com/3384495/161965936-118dceab-75ba-4c5d-87de-8c433c046371.png">

#### Troubleshooting

If any of your pods is stuck in the init phase, you can get the init containers logs with

```bash
kubectl logs <pod_name> -n <your_namespace> --all-containers
```
