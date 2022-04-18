resource "random_integer" "redis_suffix" {
  min = 1000
  max = 9999
}

locals {
  redis_name = "redis-${random_integer.redis_suffix.result}"
}

resource "azurerm_redis_cache" "default" {
  # ! The Name used for Redis needs to be globally unique
  name                = local.redis_name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  # Version
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

# ! This is open to the internet
resource "azurerm_redis_firewall_rule" "default" {
  name                = "AllowAll"
  resource_group_name = azurerm_resource_group.default.name
  redis_cache_name    = azurerm_redis_cache.default.name
  start_ip            = "0.0.0.0"
  end_ip              = "255.255.255.255"
}
