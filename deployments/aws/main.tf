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
  region = var.aws_region
}


data "template_file" "user_data" {
  template = file("${path.module}/../../templates/user_data.sh.tmpl")

  vars = {
    deployment_mode  = var.deployment_mode
    setup_demo_clone = var.setup_demo_clone ? "true" : "false"
    clone_target_url = var.clone_target_url
  }
}

module "security_group" {
  source         = "./modules/security_group"
  project_name   = var.vm_name
  vpc_id         = module.app.vpc_id    # Make sure module.app outputs vpc_id
  ssh_ip_address = var.ssh_allowed_ip
  cloud_provider = "aws"

  # Add any other variables your security_group module requires
}

module "app" {
  source                = "./modules/aws"
  vm_name               = var.vm_name
  vm_size               = var.vm_size
  aws_region            = var.aws_region   # Pass aws_region, not region
  deployment_mode       = var.deployment_mode
  ssh_password          = var.ssh_password
  auto_delete_after_24h = var.auto_delete_after_24h
  ssh_allowed_ip        = var.ssh_allowed_ip
  setup_demo_clone      = var.setup_demo_clone
  clone_target_url      = var.clone_target_url
  user_data             = data.template_file.user_data.rendered

  security_group_id     = module.security_group.security_group_id
  ssh_public_key        = ""  # key pair created inside module
}
