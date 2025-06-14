# Root provider file

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

  required_version = ">= 1.3.0"
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

provider "google" {
  credentials = file(var.gcp_key_file)
  project     = var.gcp_project
  region      = var.region
  zone        = var.zone
}

provider "azurerm" {
  features  {}

  client_id       = var.azure_client_id
  client_secret   = var.azure_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}
