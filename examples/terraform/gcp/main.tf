locals {
  # project_id = <your gcp project id>

  # Postgresql
  postgresql_availability_type = var.production_mode ? "REGIONAL" : "ZONAL"
  postgreql_maintenance_window = var.production_mode ? {
    day          = 1
    hour         = 5
    update_track = "stable"
    } : {
    day          = 5
    hour         = 7
    update_track = "canary"
  }
  postgreql_backup_configuration = var.enable_create_internal_sql_backups ? {
    enabled      = true
    pitr_enabled = true
    } : {
    enabled      = false
    pitr_enabled = false
  }
  postgresql_deletion_protection = var.postgresql_deletion_protection != null ? var.postgresql_deletion_protection : var.production_mode

  # Redis
  redis_maintenance_window = var.production_mode ? {
    day  = "MONDAY"
    hour = 5
    } : {
    day  = "FRIDAY"
    hour = 7
  }
}
