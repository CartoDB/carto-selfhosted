# https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks

locals {
  cluster_name = "aks-${random_integer.aks_suffix.result}"
}

resource "random_integer" "aks_suffix" {
  min = 1000
  max = 9999
}

# They are enabled but they way tfsec expect it it's deprecated
# tfsec:ignore:azure-container-logging
# tfsec:ignore:azure-container-use-rbac-permissions
resource "azurerm_kubernetes_cluster" "default" {
  name                = local.cluster_name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = local.cluster_name

  kubernetes_version = "1.21.9"

  # Performance
  ## Worker nodes
  default_node_pool {
    name                = "agentpool"
    vm_size             = "Standard_B2s"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
  }

  # Security
  public_network_access_enabled     = true
  api_server_authorized_ip_ranges   = ["0.0.0.0/0"] # ! World-wide access
  role_based_access_control_enabled = true

  identity {
    type = "SystemAssigned"
  }

  # Allow connecting to Kubernetes nodes via SSH
  # linux_profile {
  #   admin_username = "ubuntu"
  #   ssh_key {
  #     key_data = file(var.ssh_public_key)
  #   }
  # }

  # Networking
  # Changing this forces a new resource to be created.
  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
    network_policy    = "calico"
  }

  # Logging and Monitoring
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id
  }

  # tags = {
  #   Environment = "Development"
  # }
}

# Logging & Monitoring

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
resource "azurerm_log_analytics_workspace" "default" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "CartoDefaultLogAnalyticsWorkspace"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "default" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.default.location
  resource_group_name   = azurerm_resource_group.default.name
  workspace_resource_id = azurerm_log_analytics_workspace.default.id
  workspace_name        = azurerm_log_analytics_workspace.default.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
