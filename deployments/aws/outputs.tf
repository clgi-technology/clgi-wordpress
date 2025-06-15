output "vm_ip" {
  description = "Public IP address of the AWS instance"
  value       = module.app.public_ip
}

output "instance_id" {
  description = "AWS EC2 instance ID"
  value       = module.app.instance_id
}

output "region" {
  value = var.region
}

output "private_key_pem" {
  value     = module.app.private_key_pem
  sensitive = true
}
