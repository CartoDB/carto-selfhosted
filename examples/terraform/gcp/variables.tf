# GKE

variable "gke_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "zones" {
  type        = list(string)
  description = "The zone to host the cluster in (required if is a zonal cluster)"
}

variable "node_pool_instance_type" {
  type        = string
  description = "Node pool machine types to deploy pods in gke cluster"
}

variable "ip_range_pods_name" {
  type        = string
  description = "IP range subnet name for pods"
}

variable "ip_range_services_name" {
  type        = string
  description = "IP range subnet name for services"
}

# common

variable "production_mode" {
  description = "If production_mode is enabled we enable backup, PITR and HA"
  type        = bool
}

variable "zone" {
  description = "Gcloud project zone"
  type        = string
}

# redis

variable "redis_name" {
  type        = string
  description = "Name of the Redis instance"
}

variable "redis_memory_size_gb" {
  type        = number
  description = "Redis memory size"
  default     = 1
}

variable "redis_tier" {
  type        = string
  description = "Redis tier. If we are going to really use in production, we must use `var.production_mode`"
  default     = "BASIC"
}

variable "redis_version" {
  type        = string
  description = "Redis version to use.\nhttps://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/redis_instance#redis_version"
  default     = "REDIS_6_X"
}

# Postgres

variable "postgresl_name" {
  type        = string
  description = "Name of the postgresql instance"
}

variable "postgresql_version" {
  type        = string
  description = "Version of postgres to use.\nhttps://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version"
  default     = "POSTGRES_13"
}

variable "postgresql_deletion_protection" {
  type        = bool
  description = "Enable the deletion_protection for the database please. By default, it's the same as `production_mode` variable"
  default     = null
}

variable "postgresql_disk_autoresize" {
  type        = bool
  description = "Enable postgres autoresize"
  default     = true
}

variable "postgresql_disk_size_gb" {
  type        = number
  description = "Default postgres disk_size. Keep in mind that the value could be auto-increased using `postgresql_disk_autoresize` variable"
  default     = 10

}

variable "postgresql_tier" {
  description = "Postgres machine type to use"
  type        = string
}

## Backups

variable "enable_create_internal_sql_backups" {
  description = "Indicate if create internal db backups managed by cloud-sql"
  type        = bool
}
