<!-- omit in toc -->
# Table of Contents
- [Customizations](#customizations)
  - [Production Ready](#production-ready)
  - [Custom Service Account](#custom-service-account)
  - [How to apply the configurations](#how-to-apply-the-configurations)
  - [Available configurations](#available-configurations)
    - [Self Hosted domain](#self-hosted-domain)
      - [Custom SSL certificate](#custom-ssl-certificate)
    - [External database](#external-database)
      - [Configure SSL](#configure-ssl)
      - [Azure PostgreSQL](#azure-postgresql)
      - [Troubleshooting](#troubleshooting)
    - [External Redis](#external-redis)
      - [Configure TLS](#configure-tls)
    - [Custom buckets](#custom-buckets)
    - [Requirements](#requirements)
      - [Google Cloud Storage](#google-cloud-storage)
      - [AWS S3](#aws-s3)
      - [Azure Blob Storage](#azure-blob-storage)
    - [Enable BigQuery Oauth connections](#enable-bigquery-oauth-connections)
    - [Google Maps](#google-maps)

# Customizations

## Production Ready

The default Docker compose configuration provided by Carto works out-of-the-box, but it's **not production ready**.
There are a few things to configure in order to make the Carto installation production ready.

Mandatory:

- [Self Hosted Domain](#self-hosted-domain)

Recommended:

- [Custom SSL Certificate](#custom-ssl-certificate)
- [External Database](#external-database)

Optional:

- [External Redis](#external-redis)
- [Google Maps](#google-maps)
- [Custom Buckets](#custom-buckets)
- [Enable BigQuery OAuth connections](#enable-bigquery-oauth-connections)

## Custom Service Account

CARTO deploys a dedicated infrastructure for every self hosted installation, including a Service Account key that is required to use some of the services deployed.

If you prefer using your own GCP Service Account, please do the following prior to the Self Hosted installation:

1. Create a dedicated Service Account for the CARTO Self Hosted.

2. Contact CARTO support team and provide them the service account email.

## How to apply the configurations

Make your changes to the `customer.env` file before starting the installation steps.

> :warning: Anytime you edit the `customer.env` file to change the CARTO configuration you will need to run the `install.sh` script to update the `.env` file used by Docker compose.

## Available configurations

Here you will find the supported custom configurations you can apply to your CARTO Self Hosted deployment.

### Self Hosted domain

Configure your CARTO Self Hosted domain by updating the env var `SELFHOSTED_DOMAIN` value, which defaults to `carto3-onprem.lan`.

#### Custom SSL certificate

By default CARTO Self Hosted will generate and use a self-signed certificate if you don't provide it with your own certificate.

**Prerequisites**

- A `.crt` file with your custom domain x509 certificate.
- A `.key` file with your custom domain private key.

**Configuration**

1. Create a `certs` folder in the current directory (`carto-selfhosted`).

2. Copy your `<cert>.crt` and `<cert>.key` files in the `certs` folders (the files must be directly accesible from the server, i.e.: not protected with password and with the proper permissions).

3. Modify the following vars in the `customer.env` file:

   ```diff
   - # ROUTER_SSL_AUTOGENERATE= <1 to enable | 0 to disable>
   - # ROUTER_SSL_CERTIFICATE_PATH=/etc/nginx/ssl/<cert>.crt
   - # ROUTER_SSL_CERTIFICATE_KEY_PATH=/etc/nginx/ssl/<cert>.key
   + ROUTER_SSL_AUTOGENERATE=0
   + ROUTER_SSL_CERTIFICATE_PATH=/etc/nginx/ssl/<cert>.crt
   + ROUTER_SSL_CERTIFICATE_KEY_PATH=/etc/nginx/ssl/<cert>.key
   ```

   > Remember to replace the `<cert>` value above with the correct file name.

### External database

CARTO Self Hosted comes with an embedded PostgreSQL database that is not recommended for production installations, we recommend to use your own PostgreSQL database that lives outside the Docker ecosystem.

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
   ```

2. Uncomment the external postgres configuration:

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

3. Replace the `<FILL_ME>` placeholders with the right values.

#### Configure SSL

By default CARTO Self Hosted will try to connect to your PostgreSQL without SSL. In case you want to connect via SSL, you can configure it via the following env vars:

```bash
WORKSPACE_POSTGRES_SSL_ENABLED=true
WORKSPACE_POSTGRES_SSL_MODE=require
```

> :warning: In case you are connecting to a PostgreSQL where the SSL certificate is selfsigned or from a custom CA you will need to configure the `WORKSPACE_POSTGRES_SSL_CA` variable.

1. Copy you CA `.crt` file inside `certs` folder. Rename the CA `.crt` file to `postgresql-ssl-ca.crt`.

2. Uncomment the `WORKSPACE_POSTGRES_SSL_CA` env var in the `customer.env` file:

   ```diff
   # Only applies if Postgres SSL certificate is selfsigned, read the documentation
   - # WORKSPACE_POSTGRES_SSL_CA=/usr/src/certs/postgresql-ssl-ca.crt
   + WORKSPACE_POSTGRES_SSL_CA=/usr/src/certs/postgresql-ssl-ca.crt
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


### External Redis

CARTO comes with an embedded Redis that is not recommended for production installations, we recommend to use your own Redis that lives outside the Docker ecosystem.

Here are some Terraform examples of Redis instances created in different providers:
- [GCP Redis](../examples/terraform/gcp/redis.tf).
- [AWS Redis](../examples/terraform/aws/redis.tf).
- [Azure Redis](../examples/terraform/azure/redis.tf).

**Prerequisites**

- Redis 6 or above.

**Configuration**

1. Comment the local Redis configuration:

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

2. Uncomment the external Redis configuration:

   ```diff
   # Your custom configuration for a external redis (comment when local redis)
   - #??LOCAL_REDIS_SCALE=0
   - #??REDIS_HOST=<FILL_ME>
   - #??REDIS_PORT=<FILL_ME>
   - #??REDIS_PASSWORD=<FILL_ME>
   - #??REDIS_TLS_ENABLED=true
   # Only applies if Redis TLS certificate it's selfsigned, read the documentation
   # REDIS_TLS_CA=<FILL_ME>
   + LOCAL_REDIS_SCALE=0
   + REDIS_HOST=<FILL_ME>
   + REDIS_PORT=<FILL_ME>
   + REDIS_PASSWORD=<FILL_ME>
   + REDIS_TLS_ENABLED=true
   ```

3. Replace the `<FILL_ME>` placeholders with the right values.

#### Configure TLS

By default CARTO will try to connect to your Redis without TLS, in case you want to connect via TLS ,you can configure it via `REDIS_TLS_ENABLED` env vars in the `customer.env`file

```bash
REDIS_TLS_ENABLED=true
```

> :warning: In case you are connection to a Redis where the TLS certificate is selfsigned or from a custom CA you will need to configure the `REDIS_TLS_CA` variable

1. Copy you CA `.crt` file inside `certs` folder. Rename the CA `.crt` file to `redis-tls-ca.crt`.

2. Uncomment the `REDIS_TLS_CA` env var in the `customer.env` file.

   ```diff
   # Only applies if Redis TLS certificate it's selfsigned, read the documentation
   - # REDIS_TLS_CA=/usr/src/certs/redis-tls-ca.crt
   + REDIS_TLS_CA=/usr/src/certs/redis-tls-ca.crt
   ```

### Custom buckets

For every CARTO Self Hosted installation, we create GCS buckets in our side as part of the required infrastructure for importing data, map thumbnails and other internal data.

You can create and use your own storage buckets in any of the following supported storage providers:

- Google Cloud Storage. [Terraform code example](../examples/terraform/gcp/storage.tf).
- AWS S3. [Terraform code example](../examples/terraform/aws/storage.tf).
- Azure Storage. [Terraform code example](../examples/terraform/azure/storage.tf).

> :warning: You can only set one provider at a time.

### Requirements

- You need to create 3 buckets in your preferred Cloud provider:
  - Import Bucket
  - Client Bucket
  - Thumbnails Bucket

> There's no name constraints

> :warning: Map thumbnails storage objects (.png files) can be configured to be `public` (default) or `private`. In order to change this, set `WORKSPACE_THUMBNAILS_PUBLIC="false"` (see the examples below). For the default configuration to work, the bucket must allow public objects/blobs.

- CORS configuration: Thumbnails and Import buckets require having the following CORS headers.
  - Allowed origins: `*`
  - Allowed methods: `GET`, `PUT`, `POST`
  - Allowed headers (common): `Content-Type`, `Content-MD5`, `Content-Disposition`, `Cache-Control`
    - GCS (extra): `x-goog-content-length-range`, `x-goog-meta-filename`
    - Azure (extra): `Access-Control-Request-Headers`, `X-MS-Blob-Type`
  - Max age: `3600`

> CORS is configured at bucket level in GCS and S3, and at storage account level in Azure.

> How do I setup CORS configuration? Check the provider docs: [GCS](https://cloud.google.com/storage/docs/configuring-cors), [AWS S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/enabling-cors-examples.html), [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services#enabling-cors-for-azure-storage).

- Generate credentials to access those buckets, our supported authentication methods are:
  - GCS: Service Account Key
  - AWS: Access Key ID and Secret Access Key
  - Azure: Access Key

- Grant Read/Write permissions over the buckets to the credentials mentioned above.

#### Google Cloud Storage

In order to use Google Cloud Storage custom buckets you need to:

1. Create the buckets.

   > :warning: If you enable `Prevent public access` in the bucket properties, then set `appConfigValues.workspaceThumbnailsPublic` and `appConfigValues.workspaceImportsPublic` to `false`.

2. Configure the required [CORS settings](#requirements).

3. Create a [custom Service account](#custom-service-account).

4. Grant this service account with the following role (in addition to the buckets access): `roles/iam.serviceAccountTokenCreator`.

   > :warning: We don't recommend grating this role at project IAM level, but instead at the Service Account permissions level (IAM > Service Accounts > `your_service_account` > Permissions).

5. Set the following variables in your customer.env file:

   ```bash
   # Thumbnails bucket
   WORKSPACE_THUMBNAILS_PROVIDER='gcp'
   WORKSPACE_THUMBNAILS_PUBLIC=<true|false>
   WORKSPACE_THUMBNAILS_BUCKET=<thumbnails_bucket_name>
   WORKSPACE_THUMBNAILS_KEYFILENAME=<path_to_service_account_key_file>
   WORKSPACE_THUMBNAILS_PROJECTID=<gcp_project_id>
   
   # Client bucket
   WORKSPACE_IMPORTS_PROVIDER='gcp'
   WORKSPACE_IMPORTS_BUCKET=<client_bucket_name>
   WORKSPACE_IMPORTS_KEYFILENAME=<path_to_service_account_key_file>
   WORKSPACE_IMPORTS_PROJECTID=<gcp_project_id>
   
   # Import bucket
   IMPORT_PROVIDER='gcp'
   IMPORT_BUCKET=<import_bucket_name>
   IMPORT_KEYFILENAME=<path_to_service_account_key_file>
   IMPORT_PROJECTID=<gcp_project_id>
   ```

   > If `<BUCKET>_KEYFILENAME` is not defined  env `GOOGLE_APPLICATION_CREDENTIALS` is used as default value. When the selfhosted service account is setup in a Compute Engine instance as the default service account, there's no need to set any of these, as the containers will inherit the instance default credentials.

   > If `<BUCKET>_PROJECTID` is not defined  env `GOOGLE_CLOUD_PROJECT` is used as default value.

#### AWS S3

In order to use AWS S3 custom buckets you need to:

1. Create the buckets.

   > :warning: If you enable `Block public access` in the bucket properties, then set `appConfigValues.workspaceThumbnailsPublic` and `appConfigValues.workspaceImportsPublic` to `false`.

2. Configure the required [CORS settings](#requirements).

3. Create an IAM user and generate a programmatic key ID and secret.

4. Grant this user with read/write access permissions over the buckets.

5. Set the following variables in your customer.env file:

   ```bash
   # Thumbnails bucket
   WORKSPACE_THUMBNAILS_PROVIDER='s3'
   WORKSPACE_THUMBNAILS_PUBLIC=<true|false>
   WORKSPACE_THUMBNAILS_BUCKET=<thumbnails_bucket_name>
   WORKSPACE_THUMBNAILS_ACCESSKEYID=<aws_access_key_id>
   WORKSPACE_THUMBNAILS_SECRETACCESSKEY=<aws_access_key_secret>
   WORKSPACE_THUMBNAILS_REGION=<aws_s3_region>
   
   # Client bucket
   WORKSPACE_IMPORTS_PROVIDER='s3'
   WORKSPACE_IMPORTS_BUCKET=<client_bucket_name>
   WORKSPACE_IMPORTS_ACCESSKEYID=<aws_access_key_id>
   WORKSPACE_IMPORTS_SECRETACCESSKEY=<aws_access_key_secret>
   WORKSPACE_IMPORTS_REGION=<aws_s3_region>
   
   # Import bucket
   IMPORT_PROVIDER='s3'
   IMPORT_BUCKET=<import_bucket_name>
   IMPORT_ACCESSKEYID=<aws_access_key_id>
   IMPORT_SECRETACCESSKEY=<aws_access_key_secret>
   IMPORT_REGION=<aws_s3_region>
   ```

#### Azure Blob Storage

In order to use Azure Storage buckets (aka containers) you need to:

1. Create an storage account if you don't have one already.

2. Configure the required [CORS settings](#requirements).

3. Create the storage buckets.

   > :warning:  If you set the `Public Access Mode` to `private` in the bucket properties, then set `appConfigValues.workspaceThumbnailsPublic` and `appConfigValues.workspaceImportsPublic` to `false`.

4. Generate an Access Key, from the storage account's Security properties.

5. Set the following variables in your customer.env file:

   ```bash
   # Thumbnails bucket
   WORKSPACE_THUMBNAILS_PROVIDER='azure-blob'
   WORKSPACE_THUMBNAILS_PUBLIC=<true|false>
   WORKSPACE_THUMBNAILS_BUCKET=<thumbnails_bucket_name>
   WORKSPACE_THUMBNAILS_STORAGE_ACCOUNT=<storage_account_name>
   WORKSPACE_THUMBNAILS_STORAGE_ACCESSKEY=<access_key>
   
   # Client bucket
   WORKSPACE_IMPORTS_PROVIDER='azure-blob'
   WORKSPACE_IMPORTS_BUCKET=<client_bucket_name>
   WORKSPACE_IMPORTS_STORAGE_ACCOUNT=<storage_account_name>
   WORKSPACE_IMPORTS_STORAGE_ACCESSKEY=<access_key>
   
   # Import bucket
   IMPORT_PROVIDER='azure-blob'
   IMPORT_BUCKET=<import_bucket_name>
   IMPORT_STORAGE_ACCOUNT=<storage_account_name>
   IMPORT_STORAGE_ACCESSKEY=<access_key>
   ```

### Enable BigQuery Oauth connections

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

   ```bash
   REACT_APP_BIGQUERY_OAUTH=true
   BIGQUERY_OAUTH2_CLIENT_ID=<value_from_credentials_web_client_id>
   BIGQUERY_OAUTH2_CLIENT_SECRET=<value_from_credentials_web_client_secret>
   ```

### Google Maps

In order to enable Google Maps basemaps inside CARTO Self Hosted, you need to own a Google Maps API key and set it via `REACT_APP_GOOGLE_MAPS_API_KEY` in your customer.env file.
