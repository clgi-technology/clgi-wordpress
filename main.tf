terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws     = { source = "hashicorp/aws", version = "~> 5.0" }
    google  = { source = "hashicorp/google", version = "~> 4.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
  }
}

provider "aws" {
  region = var.region
  alias  = "aws"
}

provider "google" {
  project     = var.gcp_project
  credentials = file(var.gcp_key_file)
  region      = var.region
  zone        = var.zone
  alias       = "gcp"
}

provider "azurerm" {
  features = {}
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_secret
  tenant_id       = var.azure_tenant_id
  alias           = "azure"
}

# Conditional module instantiation using dynamic blocks
# AWS
module "aws" {
  source   = "./modules/aws"
  providers = {
    aws = aws
  }

  vm_name        = var.vm_name
  region         = var.region
  vm_size        = var.vm_size
  ssh_allowed_ip = var.ssh_allowed_ip

  # Optional workaround: wrap in a null_resource-like condition
  lifecycle {
    prevent_destroy = var.cloud_provider != "AWS"
  }

  depends_on = [null_resource.aws_guard]
}

resource "null_resource" "aws_guard" {
  count = var.cloud_provider == "AWS" ? 1 : 0
}

# GCP
module "gcp" {
  source   = "./modules/gcp"
  providers = {
    google = google
  }

  vm_name             = var.vm_name
  region              = var.region
  zone                = var.zone
  vm_size             = var.vm_size
  ssh_public_key_path = var.ssh_public_key_path
  gcp_project         = var.gcp_project
  gcp_credentials     = var.gcp_key_file

  lifecycle {
    prevent_destroy = var.cloud_provider != "GCP"
  }

  depends_on = [null_resource.gcp_guard]
}

resource "null_resource" "gcp_guard" {
  count = var.cloud_provider == "GCP" ? 1 : 0
}

# Azure
module "azure" {
  source   = "./modules/azure"
  providers = {
    azurerm = azurerm
  }

  vm_name               = var.vm_name
  region                = var.region
  vm_size               = var.vm_size
  azure_client_id       = var.azure_client_id
  azure_secret          = var.azure_secret
  azure_tenant_id       = var.azure_tenant_id
  azure_subscription_id = var.azure_subscription_id

  lifecycle {
    prevent_destroy = var.cloud_provider != "Azure"
  }

  depends_on = [null_resource.azure_guard]
}

resource "null_resource" "azure_guard" {
  count = var.cloud_provider == "Azure" ? 1 : 0
}
