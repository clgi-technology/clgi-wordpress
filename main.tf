terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws     = { source = "hashicorp/aws",     version = "~> 5.0" }
    google  = { source = "hashicorp/google",  version = "~> 4.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
  }
}

provider "aws" {
  region = var.region
  alias  = "aws"
  count  = var.cloud_provider == "AWS" ? 1 : 0
}

provider "google" {
  alias       = "google"
  project     = var.gcp_project
  region      = var.region
  credentials = var.cloud_provider == "GCP" ? var.gcp_key_file : null
  count       = var.cloud_provider == "GCP" ? 1 : 0
}

provider "azurerm" {
  alias           = "azurerm"
  features        = {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
  count           = var.cloud_provider == "Azure" ? 1 : 0
}

# Conditional module loading
module "aws" {
  source          = "./modules/aws"
  count           = var.cloud_provider == "AWS" ? 1 : 0
  region          = var.region
  vm_name         = var.vm_name
  vm_size         = var.vm_size
  ssh_cidr        = var.ssh_allowed_cidr
  ssh_password    = var.ssh_password
  deployment_mode = var.deployment_mode
  clone_url       = var.clone_target_url
}

module "gcp" {
  source          = "./modules/gcp"
  count           = var.cloud_provider == "GCP" ? 1 : 0
  region          = var.region
  zone            = var.zone
  gcp_project     = var.gcp_project
  vm_name         = var.vm_name
  vm_size         = var.vm_size
  ssh_pub_path    = var.ssh_public_key_path
  deployment_mode = var.deployment_mode
}

module "azure" {
  source              = "./modules/azure"
  count               = var.cloud_provider == "Azure" ? 1 : 0
  region              = var.region
  vm_name             = var.vm_name
  vm_size             = var.vm_size
  deployment_mode     = var.deployment_mode
}
