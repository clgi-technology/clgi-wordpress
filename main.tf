terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

provider "google" {
  project     = var.gcp_project
  credentials = file(var.gcp_credentials)
  region      = var.gcp_region
  zone        = var.gcp_zone
}

provider "azurerm" {
  features        = {}
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_secret
  tenant_id       = var.azure_tenant_id
}

# ────────────────────────────────────────────────
# AWS Module
module "aws" {
  source = "./modules/aws"
  count  = var.cloud_provider == "aws" ? 1 : 0

  providers = {
    aws = aws
  }

  region                = var.aws_region
  vm_name               = var.vm_name
  vm_size               = var.vm_size
  ssh_allowed_ip        = var.ssh_allowed_ip
  ssh_password          = var.ssh_password
  deployment_mode       = var.deployment_mode
  setup_demo_clone      = var.setup_demo_clone
  clone_target_url      = var.clone_target_url
  auto_delete_after_24h = var.auto_delete_after_24h
}

# ────────────────────────────────────────────────
# GCP Module
module "gcp" {
  source = "./modules/gcp"
  count  = var.cloud_provider == "gcp" ? 1 : 0

  providers = {
    google = google
  }

  gcp_project           = var.gcp_project
  gcp_credentials       = var.gcp_credentials
  region                = var.gcp_region
  zone                  = var.gcp_zone
  vm_name               = var.vm_name
  vm_size               = var.vm_size
  ssh_allowed_ip        = var.ssh_allowed_ip
  deployment_mode       = var.deployment_mode
  setup_demo_clone      = var.setup_demo_clone
  clone_target_url      = var.clone_target_url
  auto_delete_after_24h = var.auto_delete_after_24h
}

# ────────────────────────────────────────────────
# Azure Module
module "azure" {
  source = "./modules/azure"
  count  = var.cloud_provider == "azure" ? 1 : 0

  providers = {
    azurerm = azurerm
  }

  azure_client_id       = var.azure_client_id
  azure_secret          = var.azure_secret
  azure_tenant_id       = var.azure_tenant_id
  azure_subscription_id = var.azure_subscription_id
  region                = var.azure_region
  vm_name               = var.vm_name
  vm_size               = var.vm_size
  ssh_allowed_ip        = var.ssh_allowed_ip
  deployment_mode       = var.deployment_mode
  setup_demo_clone      = var.setup_demo_clone
  clone_target_url      = var.clone_target_url
  auto_delete_after_24h = var.auto_delete_after_24h
}
