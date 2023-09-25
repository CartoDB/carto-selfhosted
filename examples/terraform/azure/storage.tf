locals {
  # We remove everything that it's not a letter or a number
  resource_group_name_parsed = replace(var.resource_group_name, "/[^a-z0-9]/", "")
}

# FIXME: For rp
# tfsec:ignore:azure-storage-queue-services-logging-enabled
resource "azurerm_storage_account" "default" {
  # The name must be unique across all existing storage account names in Azure.
  # It must be 3 to 24 characters long, and can contain only lowercase letters
  # and numbers.
  name                = local.resource_group_name_parsed
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  # Performance
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS" # For production ready use GRS or higher

  # Networking
  allow_blob_public_access = true
  min_tls_version          = "TLS1_2" # Older versions are not secure anymore

  # Security
  blob_properties {
    cors_rule {
      allowed_origins = ["*"]
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_headers = [
        "Access-Control-Request-Headers",
        "Cache-Control",
        "Content-Disposition",
        "Content-MD5",
        "Content-Type",
        "X-MS-Blob-Type"
      ]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }
}

locals {
  # List of storage containers to create.
  storage_container = [

  ]
}

resource "azurerm_storage_container" "default" {
  for_each = toset(local.storage_container)
  # This name may only contain lowercase letters, numbers, and hyphens, and must
  # begin with a letter or a number. Each hyphen must be preceded and followed
  # by a non-hyphen character. The name must also be between 3 and 63 characters
  # long.
  name                  = each.value
  storage_account_name  = azurerm_storage_account.default.name
  container_access_type = "private"
}
