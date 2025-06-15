terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

module "aws_vm" {
  source = "../../modules/aws"

  region                = var.aws_region
  vm_name               = var.vm_name
  vm_size               = var.vm_size
  ssh_allowed_ip        = var.ssh_allowed_ip
  ssh_public_key        = var.ssh_public_key
  ssh_password          = var.ssh_password
  deployment_mode       = var.deployment_mode
  setup_demo_clone      = var.setup_demo_clone
  clone_target_url      = var.clone_target_url
  ssh_public_key_path   = var.ssh_public_key_path
  auto_delete_after_24h = var.auto_delete_after_24h
}

