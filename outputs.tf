# Root outputs.tf file

output "aws_ip" {
  value       = var.cloud_provider == "AWS" ? module.aws[0].vm_ip : null
  description = "AWS Instance Public IP"
}

output "gcp_ip" {
  value       = var.cloud_provider == "GCP" ? module.gcp[0].vm_ip : null
  description = "GCP Instance Public IP"
}

output "azure_ip" {
  value       = var.cloud_provider == "Azure" ? module.azure[0].vm_ip : null
  description = "Azure VM Public IP"
}
