output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the created resource group."
}

output "virtual_network_name" {
  value       = azurerm_virtual_network.my_terraform_vnet.name
  description = "The name of the created virtual network."
}

output "bastion_host_name" {
  value       = azurerm_bastion_host.bastion.name
  description = "The name of the created Azure Bastion Host."
}

output "bastion_public_ip" {
  value       = azurerm_public_ip.bastion_public_ip.ip_address
  description = "The public IP address of the Azure Bastion Host."
}