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

output "data_disk_id" {
  description = "ID of the data disk"
  value       = azurerm_managed_disk.data.id
}

output "data_disk_size_gb" {
  description = "Size of the data disk in GB"
  value       = azurerm_managed_disk.data.disk_size_gb
}

output "data_disk_name" {
  description = "Name of the data disk"
  value       = azurerm_managed_disk.data.name
}

# ============================================
# Phase 2: Network Infrastructure Outputs
# ============================================

# Subnet IDs
output "subnet_web_id" {
  description = "ID of the Web subnet"
  value       = azurerm_subnet.web.id
}

output "subnet_app_id" {
  description = "ID of the App subnet"
  value       = azurerm_subnet.app.id
}

output "subnet_data_id" {
  description = "ID of the Data subnet"
  value       = azurerm_subnet.data.id
}

output "subnet_mgmt_id" {
  description = "ID of the Management subnet"
  value       = azurerm_subnet.mgmt.id
}

# Subnet Address Prefixes
output "subnet_web_cidr" {
  description = "CIDR block of Web subnet"
  value       = azurerm_subnet.web.address_prefixes[0]
}

output "subnet_app_cidr" {
  description = "CIDR block of App subnet"
  value       = azurerm_subnet.app.address_prefixes[0]
}

output "subnet_data_cidr" {
  description = "CIDR block of Data subnet"
  value       = azurerm_subnet.data.address_prefixes[0]
}

output "subnet_mgmt_cidr" {
  description = "CIDR block of Management subnet"
  value       = azurerm_subnet.mgmt.address_prefixes[0]
}

# NSG Names
output "nsg_web_name" {
  description = "Name of Web NSG"
  value       = azurerm_network_security_group.web.name
}

output "nsg_app_name" {
  description = "Name of App NSG"
  value       = azurerm_network_security_group.app.name
}

output "nsg_data_name" {
  description = "Name of Data NSG"
  value       = azurerm_network_security_group.data.name
}

output "nsg_mgmt_name" {
  description = "Name of Management NSG"
  value       = azurerm_network_security_group.mgmt.name
}

# ============================================
# Bastion Host Outputs
# ============================================

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = azurerm_public_ip.bastion.ip_address
}

output "bastion_vm_name" {
  description = "Name of the bastion vm"
  value       = azurerm_linux_virtual_machine.main.name
}

output "bastion_private_ip" {
  description = "Private IP address of bastion (in mgmt subnet)"
  value       = azurerm_network_interface.bastion.private_ip_address
}

output "ssh_to_bastion" {
  description = "Command to ssh to bastion host"
  value       = "ssh -i ~/.ssh/azure_vm_key ${var.admin_username}@${azurerm_public_ip.bastion.ip_address}"
}

output "ssh_via_bastion_to_web" {
  description = "Two-step SSH to web VM via bastion"
  value       = <<-EOT
    # Step 1: SSH to bastion
    ssh -i ~/.ssh/azure_vm_key ${var.admin_username}@{azurerm_public_ip.bastion.ip_address}

    # Step 2: From bastion, SSH to web VM
    ssh ${var.admin_username}@${azurerm_network_interface.main.private_ip_address}
  EOT
}

# ============================================
# Application Tier Outputs
# ============================================

output "app_vm_name" {
  description = "Name of the application VM"
  value       = azurerm_linux_virtual_machine.app.name
}

output "app_vm_private_ip" {
  description = "Private IP address of the application VM"
  value       = azurerm_network_interface.app.private_ip_address
}

output "ssh_to_app_via_bastion" {
  description = "Command to SSH to app VM via bastion"
  value       = <<-EOT
    # Step 1: SSH to bastion
    ssh -i ~/.ssh/azure_vm_key ${var.admin_username}@${azurerm_public_ip.bastion.ip_address}
    
    # Step 2: From bastion, SSH to app VM
    ssh ${var.admin_username}@${azurerm_network_interface.app.private_ip_address}
  EOT
}

# ============================================
# Database Tier Outputs
# ============================================

output "db_vm_name" {
  description = "Name of the database VM"
  value       = azurerm_linux_virtual_machine.db.name
}

output "db_vm_private_ip" {
  description = "Private IP address of the database VM"
  value       = azurerm_network_interface.db.private_ip_address
}

output "db_connection_string" {
  description = "PostgreSQL connection string (from app tier)"
  value       = "postgresql://${var.db_user}:${var.db_password}@${azurerm_network_interface.db.private_ip_address}:5432/${var.db_name}"
  sensitive   = true
}

output "ssh_to_db_via_bastion" {
  description = "Command to SSH to database VM via bastion"
  value       = <<-EOT
    # Step 1: SSH to bastion
    ssh -i ~/.ssh/azure_vm_key ${var.admin_username}@${azurerm_public_ip.bastion.ip_address}
    
    # Step 2: From bastion, SSH to database VM
    ssh ${var.admin_username}@${azurerm_network_interface.db.private_ip_address}
  EOT
}

output "psql_test_command" {
  description = "Command to test PostgreSQL connection from app VM"
  value       = "psql -h ${azurerm_network_interface.db.private_ip_address} -U ${var.db_user} -d ${var.db_name}"
  sensitive   = false
}