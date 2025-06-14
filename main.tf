# AWS Module
module "aws" {
  source = "./modules/aws"
  count  = var.cloud_provider == "aws" ? 1 : 0

  
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
