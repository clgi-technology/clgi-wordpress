# deployments/gcp/main.tf

terraform {
  required_version = ">= 1.4.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project     = var.gcp_project_id
  region      = var.region
  credentials = var.gcp_credentials
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh.tmpl")

  vars = {
    deployment_mode  = var.deployment_mode
    setup_demo_clone = var.setup_demo_clone ? "true" : "false"
    clone_target_url = var.clone_target_url
  }
}

module "security_groups" {
  source         = "./modules/security_group"
  cloud_provider = "gcp"
  ssh_cidr       = var.ssh_allowed_ip
}

module "app" {
  source               = "./modules/gcp"
  vm_name              = var.vm_name
  vm_size              = var.vm_size
  region               = var.region
  deployment_mode      = var.deployment_mode
  ssh_public_key       = var.ssh_public_key
  ssh_password         = var.ssh_password
  auto_delete_after_24h = var.auto_delete_after_24h

  firewall_id          = module.security_groups.id
}

