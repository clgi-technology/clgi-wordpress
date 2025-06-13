provider "google" {
  project = var.gcp_project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc" {
  name = "terraform-vpc"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "terraform-subnet"
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.vm_size
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      // Include this block to assign a public IP
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  lifecycle {
    prevent_destroy = var.deployment_mode == "production" ? true : false
  }
}

resource "null_resource" "auto_delete" {
  count = var.deployment_mode == "sandbox" && var.auto_delete == "yes" ? 1 : 0

  provisioner "local-exec" {
    command = "sleep 86400 && terraform destroy -auto-approve"
  }
}
