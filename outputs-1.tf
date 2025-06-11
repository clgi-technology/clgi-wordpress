output "vm_ip" {
  description = "Public IP of the VM"
  value       = aws_instance.vm.public_ip
}
