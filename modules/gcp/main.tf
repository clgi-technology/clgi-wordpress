terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}


resource "google_compute_network" "vpc" {
  name = "${var.vm_name}-vpc"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.vm_name}-subnet"
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
}

resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.vm_size
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.name
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  tags = ["ssh"]
}
