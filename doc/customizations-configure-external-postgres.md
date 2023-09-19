### External database

CARTO Self Hosted comes with an embedded PostgreSQL database that is not recommended for production installations, we recommend to use your own PostgreSQL database that lives outside the Docker ecosystem. This database is for internal data of the CARTO Self Hosted.

Here are some Terraform examples of databases created in different providers:

- [GCP Cloud SQL](../examples/terraform/gcp/postgresql.tf).
- [AWS RDS](../examples/terraform/aws/postgresql-rds.tf).
- [Azure Database](../examples/terraform/azure/postgresql.tf).

**Prerequisites**

- PostgreSQL 11 or above

**Configuration**

Open with an editor the `customer.env` file and modify the following variables:

1. Comment the local Postgres configuration:

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
   + # In case your Postgres doesn't contain the default postgres database
   + # POSTGRES_ADMIN_DB=postgres
   ```

2. Uncomment the external Postgres configuration:

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
   # Only applies if Postgres SSL certificate is self signed, read the documentation
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
   # In case your Postgres doesn't contain the default postgres database
   # POSTGRES_ADMIN_DB=postgres
   ```

3. Replace the `<FILL_ME>` placeholders with the right values.

#### Configure SSL

By default CARTO Self Hosted will try to connect to your external PostgreSQL using SSL.

```bash
WORKSPACE_POSTGRES_SSL_ENABLED=true
WORKSPACE_POSTGRES_SSL_MODE=require
```

> :warning: In case the SSL certificate is selfsigned or from a custom CA, you will need to configure the `WORKSPACE_POSTGRES_SSL_CA` variable.
>
> 1. Copy you CA `.crt` file inside `certs` folder. Rename the CA `.crt` file to `postgresql-ssl-ca.crt`.
>
> 2. Uncomment the `WORKSPACE_POSTGRES_SSL_CA` env var in the `customer.env` file:
>
>    ```diff
>    # Only applies if Postgres SSL certificate is selfsigned, read the documentation
>    - # WORKSPACE_POSTGRES_SSL_CA=/usr/src/certs/postgresql-ssl-ca.crt
>    + WORKSPACE_POSTGRES_SSL_CA=/usr/src/certs/postgresql-ssl-ca.crt
>    ```

To connect to your external Postgresql without SSL, you'll need to configure `WORKSPACE_POSTGRES_SSL` variables accordingly:

```diff
- WORKSPACE_POSTGRES_SSL_ENABLED=true
- WORKSPACE_POSTGRES_SSL_MODE=require
+ WORKSPACE_POSTGRES_SSL_ENABLED=false
+ WORKSPACE_POSTGRES_SSL_MODE=disable
```

#### Azure PostgreSQL

In case you are connection to an Azure hosted Postgres you will need to uncomment the `WORKSPACE_POSTGRES_INTERNAL_USER` and `POSTGRES_LOGIN_USER` env vars where:

- `WORKSPACE_POSTGRES_INTERNAL_USER` - same value as `WORKSPACE_POSTGRES_USER` but without the `@db-name` prefix.
- `POSTGRES_LOGIN_USER` - same value as `POSTGRES_ADMIN_USER` but without the `@db-name` prefix.

#### Troubleshooting

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
