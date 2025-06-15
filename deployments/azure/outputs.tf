output "vm_ip" {
  description = "Public IP of the Azure VM"
  value       = module.app.public_ip
}

output "instance_id" {
  description = "Azure VM name or ID"
  value       = module.app.instance_id
}

output "region" {
  value = var.region
}
