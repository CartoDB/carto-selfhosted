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

> :warning: Map thumbnails can be configured in two different ways: public (map thumbnails storage objects are public) or private (map thumbnails storage objects are private). In order to control it, change the value of `appConfigValues.workspaceThumbnailsPublic` (boolean). Depending on this, the bucket properties (public access) may be different.

- Generate credentials to access those buckets, our supported authentication methods are:
  - GCS: Service Account Key
  - AWS: Access Key ID and Secret Access Key
  - Azure: Access Key

- Grant Read/Write permissions over the buckets to the credentials mentioned above.

## Google Cloud Storage

In order to use Google Cloud Storage custom buckets you need to:

1. Create the buckets.
   
2. Create a [custom Service account](#custom-service-account).
   
3. Grant this service account with the following role (in addition to the buckets access): `roles/iam.serviceAccountTokenCreator`. 

   > :warning: We don't recommend grating this role at project IAM level, but instead at the Service Account permissions level (IAM > Service Accounts > `your_service_account` > Permissions).

   <!--
   TODO: Add the code related to Terraform
   -->

4. Set the following variables in your customer.env file:

```bash
# Thumbnails bucket
WORKSPACE_THUMBNAILS_PROVIDER='gcp'
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

> If `<BUCKET>_PROJECTID` is not defined  env `GOOGLE_CLOUD_PROJECT` is used as default value

## Azure Blob Storage

Requires the Storage Account (name), and the Storage Access Key

### Thumbnails

```bash
WORKSPACE_THUMBNAILS_PROVIDER='azure-blob'
WORKSPACE_THUMBNAILS_BUCKET='bucket-name1'
WORKSPACE_THUMBNAILS_STORAGE_ACCOUNT='storageName'
WORKSPACE_THUMBNAILS_STORAGE_ACCESSKEY='**AccessKey**'
```

### Imports

```bash
WORKSPACE_IMPORTS_PROVIDER='azure-blob'
WORKSPACE_IMPORTS_BUCKET='bucket-name2'
WORKSPACE_IMPORTS_STORAGE_ACCOUNT='storageName'
WORKSPACE_IMPORTS_STORAGE_ACCESSKEY='**AccessKey**'
```

```bash
IMPORT_PROVIDER='azure-blob'
IMPORT_BUCKET='bucket-name3'
IMPORT_STORAGE_ACCOUNT='storageName'
IMPORT_STORAGE_ACCESSKEY='**AccessKey**'
```

### Notes

The buckets need the permissions:

![Azure Permission](images/azure-blob-permissions.png)

## AWS S3

Requires the accessKeyId, secretAccessKey and region

### Thumbnails

```bash
WORKSPACE_THUMBNAILS_PROVIDER='s3'
WORKSPACE_THUMBNAILS_BUCKET='bucketName1'
WORKSPACE_THUMBNAILS_ACCESSKEYID='***'
WORKSPACE_THUMBNAILS_SECRETACCESSKEY='****'
WORKSPACE_THUMBNAILS_REGION='us-west-1'
```

### Imports

```bash
WORKSPACE_IMPORTS_PROVIDER='s3'
WORKSPACE_IMPORTS_BUCKET='bucketName2'
WORKSPACE_IMPORTS_ACCESSKEYID='***'
WORKSPACE_IMPORTS_SECRETACCESSKEY='***'
WORKSPACE_IMPORTS_REGION='us-west-1'
```

```bash
IMPORT_PROVIDER='s3'
IMPORT_BUCKET='bucket-name3'
IMPORT_ACCESSKEYID='***'
IMPORT_SECRETACCESSKEY='***'
IMPORT_REGION='us-west-1'
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
