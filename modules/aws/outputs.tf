output "vpc_id" {
  value = try(aws_vpc.main[0].id, null)
}

output "instance_id" {
  value = try(aws_instance.vm[0].id, null)
  description = "AWS EC2 instance ID"
}

output "tags" {
  value = try(aws_instance.vm[0].tags, {})
  description = "Tags assigned to the AWS instance"
}

output "destroy_after" {
  value = try(aws_instance.vm[0].tags["destroy_after"], null)
  description = "Custom auto-delete or expiration tag, if set"
}

output "private_key_pem" {
  value     = try(tls_private_key.deployer_key[0].private_key_pem, null)
  sensitive = true
  description = "Private key to SSH into the instance"
}

output "public_ip" {
  value = try(aws_instance.vm[0].public_ip, null)
  description = "Public IP address of the AWS EC2 instance"
}

