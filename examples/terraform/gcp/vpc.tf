#tfsec:ignore:google-compute-enable-vpc-flow-logs
resource "google_compute_subnetwork" "carto_selfhosted_subnet" {
  name          = "carto-selfhosted-subnet"
  project       = local.project_id
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.carto_selfhosted_network.id
  secondary_ip_range {
    range_name    = var.ip_range_services_name
    ip_cidr_range = "192.168.1.0/24"
  }

  secondary_ip_range {
    range_name    = var.ip_range_pods_name
    ip_cidr_range = "192.168.64.0/22"
  }
}

resource "google_compute_network" "carto_selfhosted_network" {
  name                    = "carto-selfhosted-network"
  project                 = local.project_id
  auto_create_subnetworks = false
}
