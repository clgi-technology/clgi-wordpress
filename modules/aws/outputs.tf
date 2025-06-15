output "vm_ip" {
  description = "Public IP address of the AWS EC2 instance"
  value       = length(aws_instance.vm) > 0 ? aws_instance.vm[0].public_ip : null
}

output "instance_id" {
  description = "AWS EC2 instance ID"
  value       = aws_instance.vm[0].id
}

output "tags" {
  description = "Tags assigned to the AWS instance"
  value       = aws_instance.vm[0].tags
}

output "destroy_after" {
  description = "Custom auto-delete or expiration tag, if set"
  value       = try(aws_instance.vm[0].tags["destroy_after"], null)
}

output "private_key_pem" {
  description = "Private key to SSH into the instance"
  value       = tls_private_key.key[0].private_key_pem
  sensitive   = true
}

output "public_ip" {
  description = "Public IP address of the AWS EC2 instance"
  value       = aws_instance.vm[0].public_ip
}

output "instance_id" {
  description = "AWS EC2 instance ID"
  value       = aws_instance.vm[0].id
}
