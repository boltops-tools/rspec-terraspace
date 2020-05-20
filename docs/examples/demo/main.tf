resource "google_compute_network" "network" {
  name    = var.name_prefix
  project = var.project

  # Always define custom subnetworks- one subnetwork per region isn't useful for an opinionated setup
  auto_create_subnetworks = "false"

  # A global routing mode can have an unexpected impact on load balancers; always use a regional mode
  routing_mode = "REGIONAL"
}
