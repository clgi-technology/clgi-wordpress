variable "cloud_provider" {}
variable "deployment_mode" {}
variable "auto_delete_after_24h" {}
variable "setup_demo_clone" {}
variable "clone_target_url" {}
variable "vm_name" {}
variable "vm_size" {}
variable "region" {}
variable "zone" {}
variable "ssh_public_key_path" {}
variable "ssh_ip_address" {}

# AWS-specific
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_session_token" {}

# GCP-specific
variable "gcp_key_file" {}
variable "gcp_project" {}

# Azure-specific
variable "azure_client_id" {}
variable "azure_secret" {}
variable "azure_tenant_id" {}
variable "azure_subscription_id" {}

# AWS Module
module "aws" {
  source  = "./modules/aws"
  count   = var.cloud_provider == "AWS" ? 1 : 0

  providers = {
    aws = aws
  }

  vm_name             = var.vm_name
  vm_size             = var.vm_size
  region              = var.region
  ssh_ip_address      = var.ssh_ip_address
  ssh_password        = var.ssh_password
  setup_demo_clone    = var.setup_demo_clone
  clone_target_url    = var.clone_target_url
  deployment_mode     = var.deployment_mode
  auto_delete_after_24h = var.auto_delete_after_24h
}

# GCP Module
module "gcp" {
  source = "./modules/gcp"
  count  = var.cloud_provider == "GCP" ? 1 : 0

  providers = {
    google = google
  }

  vm_name             = var.vm_name
  vm_size             = var.vm_size
  region              = var.region
  zone                = var.zone
  ssh_ip_address      = var.ssh_ip_address
  ssh_password        = var.ssh_password
  setup_demo_clone    = var.setup_demo_clone
  clone_target_url    = var.clone_target_url
  deployment_mode     = var.deployment_mode
  auto_delete_after_24h = var.auto_delete_after_24h
}

# Azure Module
module "azure" {
  source = "./modules/azure"
  count  = var.cloud_provider == "Azure" ? 1 : 0

  providers = {
    azurerm = azurerm
  }

  vm_name             = var.vm_name
  vm_size             = var.vm_size
  region              = var.region
  ssh_ip_address      = var.ssh_ip_address
  ssh_password        = var.ssh_password
  setup_demo_clone    = var.setup_demo_clone
  clone_target_url    = var.clone_target_url
  deployment_mode     = var.deployment_mode
  auto_delete_after_24h = var.auto_delete_after_24h
}
