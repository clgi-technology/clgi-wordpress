output "vm_ip" {
  description = "External IP address of the GCP VM"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "instance_id" {
  description = "GCP VM name"
  value       = google_compute_instance.vm.name
}

output "labels" {
  description = "Labels assigned to the GCP instance"
  value       = google_compute_instance.vm.labels
}

output "destroy_after" {
  description = "Custom auto-delete label, if set"
  value       = try(google_compute_instance.vm.labels["destroy_after"], null)
}
