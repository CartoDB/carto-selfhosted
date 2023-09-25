#####################################################################################
# Terraform Examples:
# These are pieces of code added as configuration examples for guidance,
# therefore they may require additional resources and variable or local declarations.
#####################################################################################

locals {
  # Instance name
  redis_instance_name = "${var.redis_name}-${random_integer.random_redis.id}"
}

# Name suffix
resource "random_integer" "random_redis" {
  min = 1000
  max = 9999
}

# Redis instance
resource "google_redis_instance" "default" {
  name               = local.redis_instance_name
  project            = local.project_id
  region             = var.region
  location_id        = var.zone
  memory_size_gb     = var.redis_memory_size_gb
  auth_enabled       = true
  tier               = var.redis_tier
  redis_version      = var.redis_version
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  authorized_network = google_compute_network.carto_selfhosted_network.id
  depends_on         = [google_service_networking_connection.private_service_connection]

  maintenance_policy {
    weekly_maintenance_window {
      day = local.redis_maintenance_window.day
      start_time {
        hours = local.redis_maintenance_window.hour
      }
    }
  }
}

# Credentials stored in Google Secret Manager

resource "google_secret_manager_secret" "redis_password" {
  secret_id = "redis-auth-string-${google_redis_instance.default.name}"
  project   = local.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "redis_password" {
  secret      = google_secret_manager_secret.redis_password.id
  secret_data = google_redis_instance.default.auth_string
}
