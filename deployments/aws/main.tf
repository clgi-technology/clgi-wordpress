#deployemnts/aws/main.tf

terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

module "security_groups" {
  source         = "../../modules/security_groups"
  cloud_provider = "aws"
  ssh_cidr       = var.ssh_allowed_ip
}

module "app" {
  source               = "../../modules/aws"
  vm_name              = var.vm_name
  vm_size              = var.vm_size
  region               = var.region
  deployment_mode      = var.deployment_mode
  ssh_public_key       = var.ssh_public_key
  ssh_password         = var.ssh_password
  auto_delete_after_24h = var.auto_delete_after_24h

  security_group_id    = module.security_groups.id
}
