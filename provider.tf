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

#provider "google" {
#  project     = var.gcp_project
#  credentials = file(var.gcp_key_file)
#  region      = var.gcp_region
#  zone        = var.gcp_zone
#}

#provider "azurerm" {
#  features {}

#  subscription_id = var.azure_subscription_id
#  client_id       = var.azure_client_id
#  client_secret   = var.azure_secret
#  tenant_id       = var.azure_tenant_id
#}
