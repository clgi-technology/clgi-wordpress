output "aws_vm_ip" { 
  description = "Public IP of the VM"
  value       = aws_instance.vm[0].public_ip
}
