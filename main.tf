terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws     = { source = "hashicorp/aws", version = "~> 5.0" }
    google  = { source = "hashicorp/google", version = "~> 4.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
  }
}

# Conditional deployments
module "aws" {
  source         = "./modules/aws"
  count          = var.cloud_provider == "AWS" ? 1 : 0
  vm_name        = var.vm_name
  region         = var.region
  vm_size        = var.vm_size
  ssh_allowed_ip = var.ssh_allowed_ip
}

module "gcp" {
  source              = "./modules/gcp"
  count               = var.cloud_provider == "GCP" ? 1 : 0
  vm_name             = var.vm_name
  region              = var.region
  zone                = var.zone
  vm_size             = var.vm_size
  ssh_public_key_path = var.ssh_public_key_path
  gcp_project         = var.gcp_project
  gcp_credentials     = var.gcp_key_file
}

module "azure" {
  source                = "./modules/azure"
  count                 = var.cloud_provider == "Azure" ? 1 : 0
  vm_name               = var.vm_name
  region                = var.region
  vm_size               = var.vm_size
  azure_client_id       = var.azure_client_id
  azure_secret          = var.azure_secret
  azure_tenant_id       = var.azure_tenant_id
  azure_subscription_id = var.azure_subscription_id
}
