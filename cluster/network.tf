resource "google_compute_network" "vpc_network" {
  name                    = "${var.cluster_name}-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  network       = google_compute_network.vpc_network.id
  name          = "${var.cluster_name}-vpc-subnet"
  ip_cidr_range = "10.2.0.0/24"
  region        = var.region
  secondary_ip_range {
    range_name = "${var.cluster_name}-vpc-pod-range"
    # Left max_pods_per_node at default for now.
    # This means GKE will hand /24 slices to each node.
    # The expectation is to never be above 4 nodes at any given time.
    # A /21 range gives us 2^(24-21)=8 /24 slices, for headroom.
    ip_cidr_range = "192.168.8.0/21"
  }
}
