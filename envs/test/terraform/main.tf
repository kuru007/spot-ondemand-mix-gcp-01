terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# --------------------------
# VPC Network
# --------------------------
resource "google_compute_network" "main" {
  name                    = "${var.env}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "${var.env}-subnet"
  network       = google_compute_network.main.name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

resource "google_compute_firewall" "gke_nodes" {
  name    = "${var.env}-allow-internal"
  network = google_compute_network.main.name
  source_ranges = ["10.0.0.0/8"]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
}

# --------------------------
# GKE Cluster
# --------------------------
resource "google_container_cluster" "primary" {
  name                     = "${var.env}-cluster"
  location                 = var.zone
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  network    = google_compute_network.main.name
  subnetwork = google_compute_subnetwork.gke_subnet.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  depends_on = [google_compute_subnetwork.gke_subnet]
}

# --------------------------
# On-Demand Node Pool
# --------------------------
resource "google_container_node_pool" "ondemand" {
  name       = "${var.cluster_name}-ondemand"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2 # keep ondemand smaller
  }

  node_config {
    machine_type = var.ondemand_machine_type
    labels       = { type = "ondemand" }

    taint {
      key    = "type"
      value  = "on-demand"
      effect = "PREFER_NO_SCHEDULE"
    }

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# Spot Node Pool
resource "google_container_node_pool" "spot" {
  name       = "${var.cluster_name}-spot"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 5 # allow more spot capacity
  }

  node_config {
    machine_type = var.spot_machine_type
    labels       = { "cloud.google.com/gke-spot" = "true" }
    spot         = true

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}