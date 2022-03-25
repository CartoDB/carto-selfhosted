
# GKE
gke_cluster_name        = "gke-default"
region                  = "europe-west1"
zones                   = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
node_pool_instance_type = "n1-standard-16"
ip_range_pods_name      = "pod-ranges"
ip_range_services_name  = "services-range"

activate_apis_custom = [
  "container.googleapis.com",
  "secretmanager.googleapis.com",
]

# Postgresql
postgresl_name                     = "carto-selfhosted-postgres"
postgresql_version                 = "POSTGRES_13"
enable_create_internal_sql_backups = true
postgresql_tier                    = "db-custom-1-3840"

# Redis
redis_name = "carto-selfhosted-redis"

# common
production_mode = false
zone            = "europe-west1-b"
