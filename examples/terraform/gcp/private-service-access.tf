resource "google_compute_global_address" "service_range" {
  name          = "address"
  project       = local.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.carto_selfhosted_network.name
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = google_compute_network.carto_selfhosted_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.service_range.name]
}
