
locals {
  cluster_type = "nodepool"
  cluster_name = "${var.gke_cluster_name}-${random_integer.suffix.result}"
}

resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# tflint-ignore: terraform_module_version
module "gke" {
  source                            = "terraform-google-modules/kubernetes-engine/google"
  project_id                        = local.project_id
  name                              = local.cluster_name
  region                            = var.region
  zones                             = var.zones
  network                           = google_compute_network.carto_selfhosted_network.name
  subnetwork                        = google_compute_subnetwork.carto_selfhosted_subnet.name
  ip_range_pods                     = var.ip_range_pods_name
  ip_range_services                 = var.ip_range_services_name
  create_service_account            = true
  remove_default_node_pool          = true
  disable_legacy_metadata_endpoints = false
  default_max_pods_per_node         = 16
  node_pools = [
    {
      name           = "pool-01"
      machine_type   = var.node_pool_instance_type
      node_locations = "${var.region}-b"
      autoscaling    = true
      min_count      = 1
      max_count      = 5
      disk_size_gb   = 30
      disk_type      = "pd-standard"
      auto_upgrade   = false
    },
    {
      name           = "pool-02"
      machine_type   = var.node_pool_instance_type
      node_locations = "${var.region}-d"
      autoscaling    = true
      min_count      = 1
      max_count      = 5
      disk_size_gb   = 30
      disk_type      = "pd-standard"
      auto_upgrade   = false
    },
  ]

}
