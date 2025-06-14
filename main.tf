# AWS
provider "aws" {
  region = var.region
  alias  = "aws"
}

# GCP
provider "google" {
  credentials = file(var.gcp_key_file)
  project     = var.gcp_project
  region      = var.region
  zone        = var.zone
  alias       = "google"
}

# Azure
provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
  alias           = "azurerm"
}

##############################################################################
# AWS Module
##############################################################################

module "aws" {
  source = "./modules/aws"

  providers = {
    aws = aws
  }

  # Only include variables your module supports!
  vm_name              = var.vm_name
  vm_size              = var.vm_size
  region               = var.region
  ssh_allowed_ip       = var.ssh_allowed_cidr

  # Optional: only if you added these to module variables.tf
  ssh_password          = var.ssh_password
  setup_demo_clone      = var.setup_demo_clone
  clone_target_url      = var.clone_target_url
  deployment_mode       = var.deployment_mode
  auto_delete_after_24h = var.auto_delete_after_24h
}


##############################################################################
# GCP Module
##############################################################################

module "gcp" {
  source = "./modules/gcp"
  count  = var.cloud_provider == "GCP" ? 1 : 0

  providers = {
    google = google
  }

  vm_name               = var.vm_name
  vm_size               = var.vm_size
  region                = var.region
  zone                  = var.zone
  ssh_public_key_path   = var.ssh_public_key_path
  setup_demo_clone      = var.setup_demo_clone
  clone_target_url      = var.clone_target_url
  deployment_mode       = var.deployment_mode
  auto_delete_after_24h = var.auto_delete_after_24h
}

##############################################################################
# Azure Module
##############################################################################

module "azure" {
  source = "./modules/azure"
  count  = var.cloud_provider == "Azure" ? 1 : 0

  providers = {
    azurerm = azurerm
  }

  vm_name               = var.vm_name
  vm_size               = var.vm_size
  region                = var.region
  ssh_ip_address        = var.ssh_ip_address
  ssh_password          = var.ssh_password
  setup_demo_clone      = var.setup_demo_clone
  clone_target_url      = var.clone_target_url
  deployment_mode       = var.deployment_mode
  auto_delete_after_24h = var.auto_delete_after_24h

  azure_client_id       = var.azure_client_id
  azure_secret          = var.azure_secret
  azure_tenant_id       = var.azure_tenant_id
  azure_subscription_id = var.azure_subscription_id
}
