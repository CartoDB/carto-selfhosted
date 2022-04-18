# AKS

output "kube_config" {
  description = "AKS cluster kubeconfig for kubectl"
  value       = azurerm_kubernetes_cluster.default.kube_config_raw
  sensitive   = true
}

# Redis

output "redis_access_key" {
  description = "Redis access key"
  value       = azurerm_redis_cache.default.primary_access_key
  sensitive   = true
}

output "redis_host" {
  description = "Redis host"
  value       = azurerm_redis_cache.default.hostname
}

# Postgresql

output "postgres_host" {
  description = "Postgresql FQDN"
  value       = azurerm_postgresql_server.default.fqdn
}

output "postgres_admin_user" {
  description = "Postgresql admin username"
  value       = azurerm_postgresql_server.default.administrator_login
  sensitive   = true
}

output "postgres_admin_password" {
  description = "Postgresql admin password"
  value       = azurerm_postgresql_server.default.administrator_login_password
  sensitive   = true
}

# Storage
output "storage_account_primary_access_key" {
  description = "Storage Account Primary Access Key"
  value       = azurerm_storage_account.default.primary_access_key
  sensitive   = true
}
