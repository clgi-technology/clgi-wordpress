output "vm_ip" {
  description = "Public IP of the Azure VM"
  value       = azurerm_public_ip.public_ip.ip_address
}

output "instance_id" {
  description = "Azure VM ID"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "tags" {
  description = "Tags assigned to the Azure VM"
  value       = azurerm_linux_virtual_machine.vm.tags
}

output "destroy_after" {
  description = "Auto-delete tag value, if defined"
  value       = try(azurerm_linux_virtual_machine.vm.tags["destroy_after"], null)
}
