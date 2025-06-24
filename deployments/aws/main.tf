# Generate a random suffix to avoid key name collisions
resource "random_id" "key_suffix" {
  byte_length = 4
}

# Generate SSH Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "deploy-key-${random_id.key_suffix.hex}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# User Data Script
data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh.tmpl")

  vars = {
    deployment_mode  = var.deployment_mode
    setup_demo_clone = var.setup_demo_clone  # boolean true/false now
    clone_target_url = var.clone_target_url
    scripts_url      = var.scripts_url
    ssh_password     = var.ssh_password
  }
}

module "security_group" {
  source         = "../../modules/security_group"
  project_name   = var.vm_name
  vpc_id         = module.app.vpc_id
  ssh_ip_address = var.ssh_allowed_ip
  cloud_provider = "aws"
}

module "app" {
  source                = "../../modules/aws"
  
  vm_name               = var.vm_name
  vm_size               = var.vm_size
  aws_region            = var.aws_region
  aws_access_key        = var.aws_access_key
  aws_secret_key        = var.aws_secret_key
  aws_session_token     = var.aws_session_token
  deployment_mode       = var.deployment_mode
  ssh_password          = var.ssh_password
  ssh_private_key       = tls_private_key.ssh_key.private_key_pem
  ssh_allowed_ip        = var.ssh_allowed_ip
  auto_delete_after_24h = var.auto_delete_after_24h
  setup_demo_clone      = var.setup_demo_clone
  clone_target_url      = var.clone_target_url
  user_data             = data.template_file.user_data.rendered

  security_group_id     = module.security_group.security_group_id
  ssh_public_key        = tls_private_key.ssh_key.public_key_openssh
}

output "ssh_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "ssh_public_key" {
  value = tls_private_key.ssh_key.public_key_openssh
}

output "ssh_key_pair_name" {
  description = "Dynamically generated AWS key pair name"
  value       = aws_key_pair.generated_key.key_name
}

output "vm_public_ip" {
  description = "Public IP address of the AWS instance"
  value       = module.app.public_ip
}

output "instance_id" {
  description = "AWS EC2 instance ID"
  value       = module.app.instance_id
}

output "region" {
  value = var.aws_region
}

output "private_key_pem" {
  value     = module.app.private_key_pem
  sensitive = true
}

output "security_group_id" {
  description = "Security Group ID created by the security_group module"
  value       = module.security_group.security_group_id
}

output "auto_delete_at" {
  description = "Timestamp when deployment should auto-expire (UTC, ISO 8601)"
  value       = var.auto_delete_after_24h ? timeadd(timestamp(), "24h") : null
}

module "auto_delete" {
  source      = "../../modules/auto_delete"
  vm_name     = var.vm_name
  instance_id = module.app.instance_id

  count = var.auto_delete_after_24h ? 1 : 0
}
