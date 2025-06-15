output "vm_ip" {
  description = "Public IP address of the AWS EC2 instance"
  value       = aws_instance.vm.public_ip
}

output "instance_id" {
  description = "AWS EC2 instance ID"
  value       = aws_instance.vm.id
}

output "tags" {
  description = "Tags assigned to the AWS instance"
  value       = aws_instance.vm.tags
}

output "destroy_after" {
  description = "Custom auto-delete or expiration tag, if set"
  value       = try(aws_instance.vm.tags["destroy_after"], null)
}
