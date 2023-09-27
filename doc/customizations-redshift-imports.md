### Redshift imports

> :warning: This is currently a feature flag and it's disabled by default. Please, contact support if you are interested on using it.

CARTO selfhosted supports importing data to a Redshift cluster or serverless. Follow these instructions to setup your Redshift integration:

> :warning: This requires access to an AWS account and an existing accessible Redshift endpoint.

1. Create an AWS IAM user with programmatic access. Take note of the user's arn, key ID and key secret.

2. Create an AWS S3 Bucket:

   - ACLs should be allowed.
   - If server-side encryption is enabled, the user must be granted with permissions over the KMS key used.

3. Create an AWS IAM role with the following settings:

   1. Trusted entity type: `Custom trust policy`.
   2. Custom trust policy: Make sure to replace `<your_aws_user_arn>`.

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "AWS": "<your_aws_user_arn>"
         },
         "Action": ["sts:AssumeRole", "sts:TagSession"]
       }
     ]
   }
   ```

   3. Add permissions: Create a new permissions policy, replacing `<your_aws_s3_bucket_name>`.

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": "s3:ListBucket",
         "Resource": "arn:aws:s3:::<your_aws_s3_bucket_name>"
       },
       {
         "Effect": "Allow",
         "Action": "s3:*Object",
         "Resource": "arn:aws:s3:::<your_aws_s3_bucket_name>/*"
       }
     ]
   }
   ```

4. Add the following lines to your `customer.env` file:

```bash
IMPORT_AWS_ACCESS_KEY_ID=<aws_access_key_id>
IMPORT_AWS_SECRET_ACCESS_KEY=<aws_access_key_secret>
IMPORT_AWS_ROLE_ARN=<aws_iam_role_arn>
```

5. Perform a `docker-compose up -d` before continuing with the following steps.

6. Log into your CARTO selfhosted, go to `Data Explorer > Connections > Add new connection` and create a new Redshift connection.

7. Then go to `Settings > Advanced > Integrations > Redshift > New`, introduce your S3 Bucket name and region and copy the policy generated.

8. From the AWS console, go to your `S3 > Bucket > Permissions > Bucket policy` and paste the policy obtained in the previous step in the policy editor.

9. Go back to the CARTO Selfhosted (Redshift integration page) and check the `I have already added the S3 bucket policy` box and click on the `Validate and save button`.

10. Go to `Data Exporer > Import data > Redshift connection` and you should be able to import a local dataset to Redshift.