# VPC
resource "google_compute_network" "gke_autopilot_network" {
  name                    = "gke-autopilot-network"
  project                 = local.project_id
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "gke_autopilot_subnet" {
  name          = "gke-autopilot-subnet"
  project       = local.project_id
  ip_cidr_range = "10.5.0.0/16"
  region        = var.region
  network       = google_compute_network.gke_autopilot_network.id
}

# GKE cluster
resource "google_container_cluster" "default" {
  name     = "gke-autopilot"
  project  = local.project_id
  location = var.region

  # Private clusters use nodes that do not have external IP addresses.
  # This means that clients on the internet cannot connect to the IP addresses of the nodes.
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    # Control plane nodes are not accessible globally
    master_global_access_config {
      enabled = false
    }
  }

  # At this point, these are the only IP addresses that have access to the control plane:
  #   - The primary range of my-subnet.
  #   - The secondary range my-pods.
  # If you need to allow external networks to access Kubernetes master through HTTPS, please see:
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#master_authorized_networks_config

  release_channel {
    channel = "STABLE"
  }

  network    = google_compute_network.gke_autopilot_network.name
  subnetwork = google_compute_subnetwork.gke_autopilot_subnet.name

  ip_allocation_policy {
    # There settings are permanent and they cannot be changed once the cluster is deployed
    # Cluster default pod address range. All pods in the cluster are assigned an IP address from this range. Enter a range (in CIDR notation) within a network range, a mask, or leave this field blank to use a default range.
    # We recommend at least /21 mask for pods
    cluster_ipv4_cidr_block  = "/21"
    # Service address range. Cluster services will be assigned an IP address from this IP address range. Enter a range (in CIDR notation) within a network range, a mask, or leave this field blank to use a default range.
    # We recommend at least /24 mask for services
    services_ipv4_cidr_block = "/24"
  }

  # Enabling Autopilot for this cluster
  enable_autopilot = true
}
