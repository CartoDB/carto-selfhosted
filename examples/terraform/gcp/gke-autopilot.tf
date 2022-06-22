# Please see the Autopilot documentation
# https://github.com/CartoDB/carto-selfhosted-helm/blob/main/doc/gke/gke-autopilot.md

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

# GKE Autopilot private cluster
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

  # At this point, these are the only IP addresses that have access to the control plane:
  #   - The primary range for the subnet: google_compute_subnetwork.gke_autopilot_subnet
  #   - The secondary range for the pods: google_container_cluster.default.ip_allocation_policy.cluster_ipv4_cidr_block
  # If you need to allow external networks to access Kubernetes master through HTTPS, please see:
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#master_authorized_networks_config

  # Enabling Autopilot for this cluster
  enable_autopilot = true
}

# ServiceAccount to be using in workload identity
resource "google_service_account" "workload_identity_sa" {
  project      = local.project_id
  account_id   = "workload-identity-iam-sa"
  display_name = "A service account to be used by GKE Workload Identity"
}

# Binding between IAM SA and Kubernetes SA
resource "google_service_account_iam_binding" "gke_iam_binding" {
  service_account_id = google_service_account.workload_identity_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    # "serviceAccount:<PROJECT_ID>.svc.id.goog[<KUBERNETES_NAMESPACE>/<HELM_PACKAGE_INSTALLED_NAME>-common-backend]"
    "serviceAccount:${local.project_id}.svc.id.goog[carto/carto-common-backend]",
  ]
}
