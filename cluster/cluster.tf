resource "google_container_cluster" "primary" {
  name                = "${var.cluster_name}-gke-cluster"
  location            = var.zone
  deletion_protection = false
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.vpc_network.id
  subnetwork               = google_compute_subnetwork.vpc_subnet.id
  ip_allocation_policy {
    cluster_secondary_range_name = "${var.cluster_name}-vpc-pod-range"
  }

}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  cluster    = google_container_cluster.primary.id
  location   = var.zone
  node_count = 2
  node_config {
    spot         = true
    machine_type = "e2-medium"
    boot_disk {
      size_gb   = 20
      disk_type = "pd-standard"
    }
  }
}
