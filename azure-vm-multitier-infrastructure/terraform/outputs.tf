output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "public_ip_address" {
  description = "The public IP address of the VM"
  value       = azurerm_public_ip.main.ip_address
}

output "vm_name" {
  description = "The name of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -i ~/.ssh/azure_vm_key ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "web_url" {
  description = "URL to access the web server"
  value       = "http://${azurerm_public_ip.main.ip_address}"
}