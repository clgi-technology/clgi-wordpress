output "vm_ip" {
  description = "External IP of the GCP VM"
  value       = module.app.public_ip
}

output "instance_id" {
  description = "GCP instance ID or name"
  value       = module.app.instance_id
}

output "region" {
  value = var.region
}
