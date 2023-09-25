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
resource "azurerm_redis_cache" "default" {
  # name needs to be globally unique
  name                = local.redis_instance_name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  redis_version = 6

  # Performance
  capacity = 0
  family   = "C" # Basic/Satandard
  sku_name = "Basic"

  # Networking
  public_network_access_enabled = true
  enable_non_ssl_port           = false
  minimum_tls_version           = "1.2"
}

# Firewall
resource "azurerm_redis_firewall_rule" "default" {
  name                = "AllowAll"
  resource_group_name = azurerm_resource_group.default.name
  redis_cache_name    = azurerm_redis_cache.default.name
  # Warning: The instance will be publicly accessible
  start_ip = "0.0.0.0"
  end_ip   = "255.255.255.255"
}
