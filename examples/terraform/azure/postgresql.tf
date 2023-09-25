#####################################################################################
# Terraform Examples:
# These are pieces of code added as configuration examples for guidance,
# therefore they may require additional resources and variable or local declarations.
#####################################################################################

locals {
  postgresql_name     = "postgresql-${random_integer.postgres_suffix.result}"
  postgres_admin_user = "postgres_admin_${random_integer.postgres_admin_user.result}"
}

# Name suffix
resource "random_integer" "postgres_suffix" {
  min = 1000
  max = 9999
}

# Database instance
resource "azurerm_postgresql_server" "default" {
  name                = local.postgresql_name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  # Security
  administrator_login          = local.postgres_admin_user
  administrator_login_password = random_password.postgres_admin_password.result

  # Version
  version = "11"

  # Performance
  sku_name   = "B_Gen5_1" #  Basic
  storage_mb = 10240      # 10 GB

  # Backups
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  # Networking
  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

# Database configuration
resource "azurerm_postgresql_configuration" "default" {
  for_each = toset([
    "connection_throttling",
    "log_checkpoints",
    "log_connections"
  ])
  name                = each.value
  resource_group_name = azurerm_resource_group.default.name
  server_name         = azurerm_postgresql_server.default.name
  value               = "on"
}

# Firewall
resource "azurerm_postgresql_firewall_rule" "default" {
  name                = "AllowAll"
  resource_group_name = azurerm_resource_group.default.name
  server_name         = azurerm_postgresql_server.default.name
  # Warning: The instance will be publicly accessible
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

# Postgres user
resource "random_integer" "postgres_admin_user" {
  min = 1000
  max = 9999
}

# Postgres user's password
resource "random_password" "postgres_admin_password" {
  length           = 64
  special          = true
  override_special = "!#$%&*()-_=+[]"
}
