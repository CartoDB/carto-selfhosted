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