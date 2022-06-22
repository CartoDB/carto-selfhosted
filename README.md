# CARTO Self Hosted [Docker]

- [CARTO Self Hosted [Docker]](#carto-self-hosted-docker)
  - [Installation](#installation)
    - [Prerequisites](#prerequisites)
    - [Installation Steps](#installation-steps)
    - [Production Ready](#production-ready)
      - [External Database](#external-database)
        - [Configure SSL](#configure-ssl)
        - [Azure Postgresql](#azure-postgresql)
      - [External Redis](#external-redis)
        - [Configure TLS](#configure-tls)
      - [External Domain](#external-domain)
      - [Google Maps](#google-maps)
      - [Custom buckets](#custom-buckets)
      - [Enable BigQuery OAuth connections](#enable-bigquery-oauth-connections)
  - [Update](#update)
  - [Migrate to Kubernetes](#migrate-to-kubernetes)
  - [Troubleshooting](#troubleshooting)
    - [Cloud SQL Connection configuration](#cloud-sql-connection-configuration)

Deploy CARTO in a Self Hosted environment. It's provided in two flavours

- [Kubernetes Helm](https://github.com/CartoDB/carto-selfhosted-helm)
- [Docker compose](https://github.com/CartoDB/carto-selfhosted)

> To be able to use CARTO Self Hosted you need to [contact CARTO](https://carto.com/request-live-demo/) and sign up for a CARTO License.

## Installation

### Prerequisites

You will need a Linux machine with

- Ubuntu 18.04 or above
- 60 GB disk
- 2 CPUs (x86)
- 8 GB memory
- Docker version 20.10 or above
- Docker compose version 1.29 or above
- A TLS certificate for the domain/subdomain (if not provided a self-signed one will be generated)
- Configuration and license files received from CARTO

> :warning: CARTO provides an out-of-the-box installation that is **not production ready**. In order to make your CARTO installation production ready take a look at [Production Ready](#production-ready) section

### Installation Steps

1. Login into the machine where you are going to deploy CARTO

2. Clone this repository

```bash
git clone https://github.com/CartoDB/carto-selfhosted.git
cd carto-selfhosted
```

3. You should have received two files from CARTO, copy them in the current directory (`carto-selfhosted`)

- `customer.env`
- `key.json`

4. Configure the CARTO domain. The env var `SELFHOSTED_DOMAIN` defines the domain used by CARTO, by default this domain will point to `carto3-onprem.lan`. In order to access CARTO yo should modify your `/etc/hosts` to point `localhost` to this domain

```bash
sudo vi /etc/hosts
```

```
# Carto selfhosted
127.0.0.1 carto3-onprem.lan
```

5. Generate the `.env` file out of `customer.env` file.

```bash
bash install.sh
```

6. Bring up the environment

```bash
docker-compose up -d
```

7. Open a browser and go to http://carto3-onprem.lan

### Production Ready

The default Docker compose configuration provided by Carto works out-of-the-box, but it's **not production ready**.
There are a few things to configure in order to make the Carto installation production ready.

Recommended

- [External Database](#external-database)
- [External Domain](#external-domain)

Optional

- [External Redis](#external-redis)
- [Google Maps](#google-maps)
- [Custom Buckets](#custom-buckets)
- [Enable BigQuery OAuth connections](#enable-bigquery-oauth-connections)

> :warning: Anytime you edit the `customer.env` file to change the CARTO configuration you will need to run the `install.sh` script to updathe the `.env` file used by Docker compose

#### External Database

CARTO comes with an embedded Postgresql database that is not recommended for production installations, we recommend to use your own Postgresql database that lives outside the Docker ecosystem

**Prerequisites**

- Postgresql 11 or above

**Configuration**

Open with an editor the `customer.env` file and modify the next variables

1. Comment the local Postgres configuration

```diff
# Configuration for using a local postgres, instead of an external one (comment when external postgres)
- LOCAL_POSTGRES_SCALE=1
- WORKSPACE_POSTGRES_HOST=workspace-postgres
- WORKSPACE_POSTGRES_PORT=5432
- WORKSPACE_POSTGRES_USER=workspace_admin
- WORKSPACE_POSTGRES_PASSWORD=<verySecureRandomPassword>
- WORKSPACE_POSTGRES_DB=workspace
- WORKSPACE_POSTGRES_SSL_ENABLED=false
- WORKSPACE_POSTGRES_SSL_MODE=disable
- POSTGRES_ADMIN_USER=postgres
- POSTGRES_ADMIN_PASSWORD=<verySecureRandomPassword>
+ # LOCAL_POSTGRES_SCALE=1
+ # WORKSPACE_POSTGRES_HOST=workspace-postgres
+ # WORKSPACE_POSTGRES_PORT=5432
+ # WORKSPACE_POSTGRES_USER=workspace_admin
+ # WORKSPACE_POSTGRES_PASSWORD=<verySecureRandomPassword>
+ # WORKSPACE_POSTGRES_DB=workspace
+ # WORKSPACE_POSTGRES_SSL_ENABLED=false
+ # WORKSPACE_POSTGRES_SSL_MODE=disable
+ # POSTGRES_ADMIN_USER=postgres
+ # POSTGRES_ADMIN_PASSWORD=<verySecureRandomPassword>
```

2. Uncomment the external postgres configuration

```diff
# Your custom configuration for an external postgres database (comment when local postgres)
- # LOCAL_POSTGRES_SCALE=0
- # WORKSPACE_POSTGRES_HOST=<FILL_ME>
- # WORKSPACE_POSTGRES_PORT=<FILL_ME>
- # WORKSPACE_POSTGRES_USER=workspace_admin
- # WORKSPACE_POSTGRES_PASSWORD=<FILL_ME>
- # WORKSPACE_POSTGRES_DB=workspace
- # WORKSPACE_POSTGRES_SSL_ENABLED=true
- # WORKSPACE_POSTGRES_SSL_MODE=require
# Only applies if Postgres SSL certificate is selfsigned, read the documentation
# WORKSPACE_POSTGRES_SSL_CA=/usr/src/certs/postgresql-ssl-ca.crt
- # POSTGRES_ADMIN_USER=<FILL_ME>
- # POSTGRES_ADMIN_PASSWORD=<FILL_ME>
+ LOCAL_POSTGRES_SCALE=0
+ WORKSPACE_POSTGRES_HOST=<FILL_ME>
+ WORKSPACE_POSTGRES_PORT=<FILL_ME>
+ WORKSPACE_POSTGRES_USER=workspace_admin
+ WORKSPACE_POSTGRES_PASSWORD=<FILL_ME>
+ WORKSPACE_POSTGRES_SSL_ENABLED=true
+ WORKSPACE_POSTGRES_SSL_MODE=require
+ WORKSPACE_POSTGRES_DB=workspace
+ POSTGRES_ADMIN_USER=<FILL_ME>
+ POSTGRES_ADMIN_PASSWORD=<FILL_ME>
```

3. Fill the `<FILL_ME>` parameters

##### Configure SSL

By default CARTO will try to connect to your Postgresql without SSL. In case you want to connect via SSL, you can configure it via the next env vars

```
WORKSPACE_POSTGRES_SSL_ENABLED=true
WORKSPACE_POSTGRES_SSL_MODE=require
```

> :warning: In case you are connecting to a Postgresql where the SSL certificate is selfsigned or from a custom CA you will need to configure the `WORKSPACE_POSTGRES_SSL_CA` variable

1. Copy you CA `.crt` file inside `certs` folder. Rename the CA `.crt` file to `postgresql-ssl-ca.crt`
2. Uncomment the `WORKSPACE_POSTGRES_SSL_CA` env var in the `customer.env` file

```diff
# Only applies if Postgres SSL certificate is selfsigned, read the documentation
- # WORKSPACE_POSTGRES_SSL_CA=/usr/src/certs/postgresql-ssl-ca.crt
+ WORKSPACE_POSTGRES_SSL_CA=/usr/src/certs/postgresql-ssl-ca.crt
```

##### Azure Postgresql

In case you are connection to an Azure hosted Postgres you will need to uncomment the `WORKSPACE_POSTGRES_INTERNAL_USER` and `POSTGRES_LOGIN_USER` env vars where

- `WORKSPACE_POSTGRES_INTERNAL_USER` - same value as `WORKSPACE_POSTGRES_USER` but without the `@db-name` prefix
- `POSTGRES_LOGIN_USER` - same value as `POSTGRES_ADMIN_USER` but without the `@db-name` prefix

#### External Redis

CARTO comes with an embedded Redis that is not recommended for production installations, we recommend to use your own Redis that lives outside the Docker ecosystem

**Prerequisites**

- Redis 6 or above

**Configuration**

1. Comment the local Redis configuration

```diff
# Configuration for using a local redis, instead of a external one (comment when external redis)
- LOCAL_REDIS_SCALE=1
- REDIS_HOST=redis
- REDIS_PORT=6379
- REDIS_TLS_ENABLED=false
+ # LOCAL_REDIS_SCALE=1
+ # REDIS_HOST=redis
+ # REDIS_PORT=6379
+ # REDIS_TLS_ENABLED=false
```

2. Uncomment the external Redis configuration

```diff
# Your custom configuration for a external redis (comment when local redis)
- # LOCAL_REDIS_SCALE=0
- # REDIS_HOST=<FILL_ME>
- # REDIS_PORT=<FILL_ME>
- # REDIS_PASSWORD=<FILL_ME>
- # REDIS_TLS_ENABLED=true
# Only applies if Redis TLS certificate it's selfsigned, read the documentation
# REDIS_TLS_CA=<FILL_ME>
+ LOCAL_REDIS_SCALE=0
+ REDIS_HOST=<FILL_ME>
+ REDIS_PORT=<FILL_ME>
+ REDIS_PASSWORD=<FILL_ME>
+ REDIS_TLS_ENABLED=true
```

3. Fill the `<FILL_ME>` parameters

##### Configure TLS

By default CARTO will try to connect to your Redis without TLS, in case you want to connect via TLS ,you can configure it via `REDIS_TLS_ENABLED` env vars in the `customer.env`file

```
REDIS_TLS_ENABLED=true
```

> :warning: In case you are connection to a Redis where the TLS certificate is selfsigned or from a custom CA you will need to configure the `REDIS_TLS_CA` variable

1. Copy you CA `.crt` file inside `certs` folder. Rename the CA `.crt` file to `redis-tls-ca.crt`
2. Uncomment the `REDIS_TLS_CA` env var in the `customer.env` file

```diff
# Only applies if Redis TLS certificate it's selfsigned, read the documentation
- # REDIS_TLS_CA=/usr/src/certs/redis-tls-ca.crt
+ REDIS_TLS_CA=/usr/src/certs/redis-tls-ca.crt
```

#### External Domain

The value defined at `SELFHOSTED_DOMAIN` should be the domain that points to the CARTO installation. By default this domain points to `carto3-onprem.lan` but you can configure a custom one

**Prerequisites**

- A `.crt` file with your custom domain x509 certificate
- A `.key` file with your custom domain private key

**Configuration**

1. Create a `certs` folder in the current directory (`carto-selfhosted`)
2. Copy your `<cert>.crt` and `<cert>.key` files in the `certs` folders (the files must be directly accesible from the server, i.e.: not protected with password and with the proper permissions)
3. Modify the next vars in the `customer.env` file

```diff
- # ROUTER_SSL_AUTOGENERATE= <1 to enable | 0 to disable>
- # ROUTER_SSL_CERTIFICATE_PATH=/etc/nginx/ssl/<cert>.crt
- # ROUTER_SSL_CERTIFICATE_KEY_PATH=/etc/nginx/ssl/<cert>.key
+ ROUTER_SSL_AUTOGENERATE=0
+ ROUTER_SSL_CERTIFICATE_PATH=/etc/nginx/ssl/<cert>.crt
+ ROUTER_SSL_CERTIFICATE_KEY_PATH=/etc/nginx/ssl/<cert>.key
```

> Remember to change the `<cert>` value with the correct file name

#### Google Maps

If you have a API KEY for Google Maps you can set it on `REACT_APP_GOOGLE_MAPS_API_KEY` (optional)

#### Custom buckets

In case you want to use your own cloud buckets, read the information in `customer.env` and uncomment the supported provider (AWS S3, GCP Buckets or Azure Buckets). Fill in the [credentials](doc/buckets.md).

#### Enable BigQuery OAuth connections

This feature allows users to create a BigQuery connection using `Sign in with Google` instead of providing a service account key. 

> :warning: Connections created with OAuth cannot be shared with other organization users.

1. Create an OAuth consent screen inside the desired GCP project.
   - Introduce an app name and a user support email.
   - Add an authorized domain (the one used in your email).
   - Add another email as dev contact info (it can be the same).
   - Add the following scopes: `./auth/userinfo.email`, `./auth/userinfo.profile` & `./auth/bigquery`.

2. Create an OAuth credentials.
   - Type: Web application.
   - Authorized JavaScript origins: `https://<your_selfhosted_domain>`.
   - Authorized redirect URIs: `https://<your_selfhosted_domain>/connections/bigquery/oauth`.
   - Download the credentials file.

3. In your selfhosted's customer.env file, set the following vars with the values from the credentials file:
```
REACT_APP_BIGQUERY_OAUTH=true
BIGQUERY_OAUTH2_CLIENT_ID=<value_from_credentials_web_client_id>
BIGQUERY_OAUTH2_CLIENT_SECRET=<value_from_credentials_web_client_secret>
```

## Update

To update you CARTO Self Hosted to the newest version you will need to:

```bash
# Go to CARTO installation directory
cd carto-selfhosted
# Pull last changes
git pull
# Apply the changes from the old customer.env to the new customer.env
cp customer.env customer.env.bak
# Generate the .env file
bash install.sh
# Recreate the containers
docker-compose up -d
```

## Migrate to Kubernetes

To migrate your CARTO Self Hosted from Docker Compose installation to
[Kubernetes/Helm](https://github.com/CartoDB/carto-selfhosted-helm) you need to follow these steps:

⚠️ Migration incurs in downtime. To minimize it, reduce the DNS TTL before starting the process

- Preconditions:

  - You have a running Self Hosted deployed with Docker Compose i.e using a Google Compute engine instance.
  - You have configured external databases (Redis and PostgreSQL).
  - You have a K8s cluster to deploy the new self hosted and credentials to deploy.
  - You have received a new customer package from CARTO (with files for Kubernetes and for Docker). If you do not
    have them, please contact Support.

- Steps to migrate
  1.  [Update](#update) Docker installation to the latest release with the customer package received
  2.  Allow network connectivity from k8s nodes to your pre-existing databases. [i.e (Cloud SQL connection notes](https://github.com/CartoDB/carto-selfhosted/README.md#cloud-sql-connection-configuration))
  3.  Create a `customizations.yaml` following [this instructions](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations). Keep the same external database connection settings you are using in CARTO for Docker. [Postgres](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-postgres) and [Redis](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-redis).

> ⚠️ NOTE: Do not trust the default values and fill all variables related to database connections, example:

```yaml
externalPostgresql:
  host: "<yourPostgresqlHost>"
  adminUser: postgres
  adminPassword: <adminPassword>
  password: <userPassword>
  database: workspace
  user: workspace_admin
  sslEnabled: true
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

4.  Create a `customizations.yaml` following [these instructions](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations). Keep the same external database connection settings you are using in CARTO for Docker. [Postgres](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-postgres) and [Redis](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-redis).

5.  Shut down you CARTO for Docker installation: `docker-compose down` ⚠️ From this point, the service is down.
6.  Deploy to your cluster. Follow the [installation steps](https://github.com/CartoDB/carto-selfhosted-helm#installation)
7.  Check pods are running and stable with `kubectl get pods <-n your_namespace>`
8.  Change DNS records to point to the new service (`helm install` will point how to get the IP or DNS), it will take some time to propagate.
9.  Test your CARTO Self Hosted for Kubernetes installation. Service is restored.

If for whatever reason the installation did not go as planned. You can bring back the docker installation and point back your DNS to it.

## Troubleshooting

### Cloud SQL Connection configuration

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
