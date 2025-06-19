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
