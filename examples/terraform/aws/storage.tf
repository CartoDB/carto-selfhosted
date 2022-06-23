#####################################################################################
# Terraform Examples:
# These are pieces of code added as configuration examples for guidance,
# therefore they may require additional resources and variable or local declarations.
#####################################################################################

locals {
  # List of storage buckets to create
  storage_buckets = [
    "mycarto-import-s3-bucket",
    "mycarto-client-s3-bucket",
    "mycarto-thumbnails-s3-bucket",
  ]
}

# S3 Buckets
resource "aws_s3_bucket" "default" {
  for_each = toset(local.storage_buckets)
  bucket   = each.value
  acl      = "private"

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_headers = [
      "Content-Type",
      "Content-MD5",
      "Content-Disposition",
      "Cache-Control"
    ]
  }
  versioning {
    enabled = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.default.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# Block public access setting
resource "aws_s3_bucket_public_access_block" "default" {
  for_each                = aws_s3_bucket.default
  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#KMS key for data encryption
resource "aws_kms_key" "default" {
  description         = "Default"
  enable_key_rotation = true
}
