locals {
  bucket_client_name       = "${local.project_id}-client-storage"
  bucket_thumbnails_name   = "${local.project_id}-thumbnails-storage"
  bucket_import_name       = "${local.project_id}-import-storage"
  carto_service_account_id = "carto-selfhosted-serv-account"
}

## GCS

# Client storage bucket
resource "google_storage_bucket" "client_storage" {
  name     = local.bucket_client_name
  project  = local.project_id
  location = var.region

  uniform_bucket_level_access = true

  cors {
    origin = ["*"]
    method = ["GET", "PUT", "POST", ]
    response_header = [
      "Content-Type",
      "Content-MD5",
      "Content-Disposition",
      "Cache-Control",
      "x-goog-content-length-range",
      "x-goog-meta-filename"
    ]
    max_age_seconds = 3600
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_binding" "bucket_client_storage_workspace_api" {
  bucket  = local.bucket_client_name
  role    = "roles/storage.admin"
  members = ["serviceAccount:${google_service_account.carto_selfhosted_service_account.email}"]
}

# Thumbnails storage bucket
resource "google_storage_bucket" "thumbnails_storage" {
  name     = local.bucket_thumbnails_name
  project  = local.project_id
  location = var.region

  uniform_bucket_level_access = true

  cors {
    origin = ["*"]
    method = ["GET", "PUT", "POST", ]
    response_header = [
      "Content-Type",
      "Content-MD5",
      "Content-Disposition",
      "Cache-Control",
      "x-goog-content-length-range",
      "x-goog-meta-filename"
    ]
    max_age_seconds = 3600
  }

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_binding" "bucket_thumbnails_storage_workspace_api" {
  bucket  = local.bucket_thumbnails_name
  role    = "roles/storage.admin"
  members = ["serviceAccount:${google_service_account.carto_selfhosted_service_account.email}"]
}

# Import storage bucket
resource "google_storage_bucket" "import_storage" {
  name     = local.bucket_import_name
  project  = local.project_id
  location = var.region

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_binding" "import_storage_import" {
  bucket  = local.bucket_import_name
  role    = "roles/storage.admin"
  members = ["serviceAccount:${google_service_account.carto_selfhosted_service_account.email}"]
}


## IAM

# Service account for the self hosted
resource "google_service_account" "carto_selfhosted_service_account" {
  project      = local.project_id
  account_id   = local.carto_service_account_id
  display_name = "Carto Self Hosted Service Account"
}

# Allows Carto self hosted service account to create signedUrls
resource "google_service_account_iam_member" "carto_selfhosted_service_account_token_creator" {
  service_account_id = google_service_account.carto_selfhosted_service_account.id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.carto_selfhosted_service_account.email}"
}
