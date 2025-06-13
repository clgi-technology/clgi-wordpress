output "aws_ip" {
  value       = module.aws[0].vm_ip
  description = "AWS Instance Public IP"
  condition   = var.cloud_provider == "AWS"
}

output "gcp_ip" {
  value       = module.gcp[0].vm_ip
  description = "GCP Instance Public IP"
  condition   = var.cloud_provider == "GCP"
}

output "azure_ip" {
  value       = module.azure[0].vm_ip
  description = "Azure VM Public IP"
  condition   = var.cloud_provider == "Azure"
}
