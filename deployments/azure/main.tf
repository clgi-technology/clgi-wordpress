# deployments/azure/main.tf
terraform {
  required_version = ">= 1.4.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features = {}

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
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
  cloud_provider = "azure"
  ssh_cidr       = var.ssh_allowed_ip
}

module "app" {
  source               = "./modules/azure"
  vm_name              = var.vm_name
  vm_size              = var.vm_size
  region               = var.region
  deployment_mode      = var.deployment_mode
  ssh_public_key       = var.ssh_public_key
  ssh_password         = var.ssh_password
  auto_delete_after_24h = var.auto_delete_after_24h

  nsg_id               = module.security_groups.id
}

