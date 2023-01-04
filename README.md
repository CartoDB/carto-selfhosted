<!-- omit in toc -->
# Table of Contents

- [CARTO Self Hosted [Docker]](#carto-self-hosted-docker)
  - [Installation](#installation)
    - [Prerequisites](#prerequisites)
    - [Deployment Customizations](#deployment-customizations)
    - [Installation Steps](#installation-steps)
    - [Post-installation Checks](#post-installation-checks)
  - [Update](#update)
  - [Uninstall](#uninstall)
  - [Migrate to Kubernetes](#migrate-to-kubernetes)
    - [Preconditions](#preconditions)
    - [Steps](#steps)

# CARTO Self Hosted [Docker]

This repository contains the necessary files for deploying a CARTO Self Hosted installation in your own cloud infrastructure using `docker-compose`.

To be able to run CARTO Self Hosted you need to have a license. [Contact CARTO](https://carto.com/request-live-demo/) to get one.

If you are looking for another installation method, CARTO Self Hosted is provided in two flavors:

- [Kubernetes Helm](https://github.com/CartoDB/carto-selfhosted-helm)
- [Docker compose](https://github.com/CartoDB/carto-selfhosted)

## Installation

> :warning: CARTO provides an out-of-the-box installation that is **not production ready**. In order to make your CARTO installation production ready take a look at the [customization section](customizations/README.md).

### Prerequisites

You will need a Linux machine with at least:

- Ubuntu 18.04 or above
- 60 GB disk
- 2 CPUs (x86)
- 8 GB memory
- Docker version 20.10 or above
- Docker compose version 1.29 or above
- A TLS certificate for the domain/subdomain (if not provided a self-signed one will be generated)
- Configuration and license files received from CARTO
- Internet HTTP/HTTPS access from the machine to the [whitelisted domains list](doc/whitelisted_domains.md)

> Note that you should additionally allow access to any datawarehouse endpoint configured.

### Deployment Customizations

Please, read the available [customization](customizations/README.md) options.

### Installation Steps

1. Log into the machine where you are going to deploy CARTO.

2. Clone this repository:

   ```bash
   git clone https://github.com/CartoDB/carto-selfhosted.git
   cd carto-selfhosted
   ```

3. After contacting CARTO, you should have received two files, copy them in the current directory (`carto-selfhosted`):
   - `customer.env`
   - `key.json`

4. Configure your CARTO Self Hosted domain by updating the env var `SELFHOSTED_DOMAIN` value, which defaults to `carto3-onprem.lan`. In order to access your CARTO Self Hosted you should modify your `/etc/hosts` file to point `localhost` to this domain:

   ```bash
   sudo vi /etc/hosts
   ```

   ```bash
   # Carto Self Hosted
   127.0.0.1 carto3-onprem.lan
   ```

5. Configure your deployment. Please, read the available [customization options](customizations/README.md).

6. Run the `install.sh` script to generate the `.env` file out of the `customer.env` file:

   ```bash
   bash install.sh
   ```

7. Bring up the environment:

   ```bash
   docker-compose up -d
   ```

8. Open a browser and go to `https://carto3-onprem.lan` (or the custom domain configured).

### Post-installation Checks

In order to verify CARTO Self Hosted was correctly installed and it's functional, we recommend performing the following checks:

1. Check all the containers are up and running:

   ```bash
   docker-compose ps
   ```

   > All containers should be in state `Up`, except for `workspace-migrations` which state should be `Exit 0`, meaning the database migrations finished correctly.

2. Sign in to your Self Hosted, create a user and a new organization.

3. Go to the `Connections` page, in the left-hand menu, create a new connection to one of the available providers.

4. Go to the `Data Explorer` page, click on the `Upload` button right next to the `Connections` panel. Import a dataset from a local file.

5. Go back to the `Maps` page, and create a new map.

6. In this new map, add a new layer from a table using the connection created in step 3.

7. Create a new layer from a SQL Query to the same table. You can use a simple query like:

   ```bash
   SELECT * FROM <dataset_name.table_name> LIMIT 100;
   ```

8. Create a new layer from the dataset imported in step 4.

9. Make the map public, copy the sharing URL and open it in a new incognito window.

10. Go back to the `Maps` page, and verify your map appears there and the map thumbnail represents the latest changes you made to the map.

## Update

To update you CARTO Self Hosted to the newest version you will need run the following commands:

1. Go to the CARTO installation directory:

   ```bash
   cd carto-selfhosted
   ```

2. Pull last changes from the origin repo:

   ```bash
   git pull
   ```

3. Save a backup copy of your current `customer.env`:

   ```bash
   mv customer.env customer.env.bak
   ```

4. Download the latest customer package (containing `customer.env` and `key.json` files) using [this tool](tools/). Then unzip the file.

5. Copy the new customer.env file in the installation directory:

   ```bash
   cp /new_file_location/customer.env .
   ```

6. Open side by side `customer.env` and `customer.env.bak` and apply the customizations from `customer.env.bak` in the new `customer.env`

7. Generate the `.env` file

   ```bash
   bash install.sh
   ```

8. Recreate the containers

   ```bash
   docker-compose up -d
   ```

## Uninstall

You can just stop the Self Hosted services (including removing any volumes from the system) and delete the `carto-selfhosted` directory.

> :warning: In case you are running a local Postgres database (which is not recommended for Production environments), take into account that removing the docker volumes will delete the database information and your CARTO Self Hosted users information with it.

```bash
docker-compose down -V
```

## Migrate to Kubernetes

To migrate your CARTO Self Hosted from Docker Compose installation to
[Kubernetes/Helm](https://github.com/CartoDB/carto-selfhosted-helm) you need to follow these steps:

> :warning: Migration incurs in downtime. To minimize it, reduce the DNS TTL before starting the process

### Preconditions

- You have a running Self Hosted deployed with Docker Compose i.e using a Google Compute engine instance.
- You have configured external databases (Redis and PostgreSQL).
- You have a K8s cluster to deploy the new self hosted and credentials to deploy.
- You have received a new customer package from CARTO (with files for Kubernetes and for Docker). If you do not have them, please contact Support.

### Steps

1. [Update](#update) Docker installation to the latest release with the customer package received.

2. Allow network connectivity from k8s nodes to your pre-existing databases. [i.e (Cloud SQL connection notes](https://github.com/CartoDB/carto-selfhosted/README.md#cloud-sql-connection-configuration)).

3. Create a `customizations.yaml` following [this instructions](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations). Keep the same external database connection settings you are using in CARTO for Docker. [Postgres](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-postgres) and [Redis](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-redis).

   > :warning: NOTE: Do not trust the default values and fill all variables related to database connections, example:

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

4. Create a `customizations.yaml` following [these instructions](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations). Keep the same external database connection settings you are using in CARTO for Docker. [Postgres](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-postgres) and [Redis](https://github.com/CartoDB/carto-selfhosted-helm/tree/main/customizations#configure-external-redis).

5. Shut down you CARTO for Docker installation: `docker-compose down`.

   > Once you execute this, the service is down.

6. Deploy to your cluster. Follow the [installation steps](https://github.com/CartoDB/carto-selfhosted-helm#installation).

7. Check pods are running and stable with `kubectl get pods <-n your_namespace>`.

8. Change DNS records to point to the new service (`helm install` will point how to get the IP or DNS), it will take some time to propagate.

9. Test your CARTO Self Hosted for Kubernetes installation. Service is restored.

> If for whatever reason the installation did not go as planned. You can bring back the docker installation and point back your DNS to it.
