#####################################################################################
# Terraform Examples:
# These are pieces of code added as configuration examples for guidance,
# therefore they may require additional resources and variable or local declarations.
#####################################################################################

# Cloud SQL instance
resource "google_sql_database_instance" "default" {
  name                = var.postgresl_name
  project             = local.project_id
  database_version    = var.postgresql_version
  deletion_protection = local.postgresql_deletion_protection
  region              = var.region
  settings {
    disk_autoresize   = var.postgresql_disk_autoresize
    disk_size         = var.postgresql_disk_size_gb
    disk_type         = var.production_mode ? "PD_SSD" : "PD_HDD"
    tier              = var.postgresql_tier
    availability_type = local.postgresql_availability_type

    user_labels = {
      "owner" = "product"
    }

    dynamic "database_flags" {
      for_each = {
        log_checkpoints    = "on"
        log_connections    = "on"
        log_disconnections = "on"
        log_lock_waits     = "on"
        log_temp_files     = "0"
      }
      iterator = flag

      content {
        name  = flag.key
        value = flag.value
      }
    }

    ip_configuration {
      # Necessary to connect via Unix sockets
      # https://cloud.google.com/sql/docs/mysql/connect-run#connecting_to
      ipv4_enabled    = true
      private_network = google_compute_network.carto_selfhosted_network.id
      require_ssl     = false
    }

    location_preference {
      zone = var.zone
    }

    maintenance_window {
      day          = local.postgreql_maintenance_window.day
      hour         = local.postgreql_maintenance_window.hour
      update_track = local.postgreql_maintenance_window.update_track
    }

    backup_configuration {
      enabled                        = local.postgreql_backup_configuration.enabled
      point_in_time_recovery_enabled = local.postgreql_backup_configuration.pitr_enabled
      backup_retention_settings {
        retained_backups = 30
      }
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = false
      record_client_address   = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Credentials

## Postgres Admin User

resource "google_sql_user" "postgres_admin_user" {
  name     = "postgres"
  project  = local.project_id
  instance = google_sql_database_instance.default.name
  type     = "BUILT_IN"
  password = random_password.postgres-admin-user-password.result
  lifecycle {
    ignore_changes = [
      type
    ]
  }
}

## Postgres Admin Password

resource "random_password" "postgres-admin-user-password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  number  = true
}

resource "google_secret_manager_secret" "postgres_admin_user_password_secret" {
  secret_id = "postgres-admin-password-${google_sql_database_instance.default.name}"
  project   = local.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "cloudrun_admin_user_password_secret_version" {
  secret      = google_secret_manager_secret.postgres_admin_user_password_secret.id
  secret_data = random_password.postgres-admin-user-password.result
}
