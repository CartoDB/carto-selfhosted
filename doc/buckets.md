# Custom buckets


For every CARTO Self Hosted installation, we create GCS buckets in our side as part of the required infrastructure for importing data, map thumbnails and other internal data. 

You can create and use your own storage buckets in any of the following supported storage providers:

- Google Cloud Storage
- AWS S3
- Azure Storage

> :warning: You can only set one provider at a time.

<!--
TODO: Add the code related to Terraform
-->

## Requirements

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

## Google Cloud Storage

In order to use Google Cloud Storage custom buckets you need to:

1. Create the buckets.
   
2. Configure the required CORS [settings](#requirements).
   
3. Create a [custom Service account](#custom-service-account).
   
4. Grant this service account with the following role (in addition to the buckets access): `roles/iam.serviceAccountTokenCreator`. 

   > :warning: We don't recommend grating this role at project IAM level, but instead at the Service Account permissions level (IAM > Service Accounts > `your_service_account` > Permissions).

   <!--
   TODO: Add the code related to Terraform
   -->

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

## AWS S3

In order to use AWS S3 custom buckets you need to:

1. Create the buckets. If you enable `Block public access` in the bucket properties, make sure you set `WORKSPACE_THUMBNAILS_PUBLIC` to `false`.

2. Configure the required CORS [settings](#requirements).

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

## Azure Blob Storage

In order to use Azure Storage buckets (aka containers) you need to:

1. Create an storage account if you don't have one already.

2. Configure the required CORS [settings](#requirements).

3. Create the storage buckets. If you set the `Public Access Mode` to `private` in the bucket properties, make sure you set `WORKSPACE_THUMBNAILS_PUBLIC` to `false`.

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

### Notes

To enable use in thumbnails and imports the bucket must have CORS configured in AWS:

Permissions > Cross-origin resource sharing (CORS)

example:

```json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "PUT",
            "POST",
            "DELETE"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": []
    }
]

```
