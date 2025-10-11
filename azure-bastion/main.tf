# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = random_pet.prefix.id
  location = var.resource_group_location
}

# Azure Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                = "${random_pet.prefix.id}-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}

# Network Interface for VM 1
resource "azurerm_network_interface" "linux_vm_nic" {
  name                = "vm1-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "vm1-NIC-configuration"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Linux  VM 1 
resource "azurerm_linux_virtual_machine" "vm1" {
  name                  = "${random_pet.prefix.id}-vm1"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.linux_vm_nic.id]

  location = azurerm_resource_group.rg.location
  size     = "Standard_D2s_v3"

  os_disk {
    name                 = "vm1-Disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}

# Network Interface for VM 2
resource "azurerm_network_interface" "windows_vm_nic" {
  name                = "vm2-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "vm2-NIC-configuration"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Windows  VM 2 
resource "azurerm_windows_virtual_machine" "vm2" {
  name                  = "${random_pet.prefix.id}-vm2"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.windows_vm_nic.id]

  location = azurerm_resource_group.rg.location
  size     = "Standard_D2s_v3"

  os_disk {
    name                 = "vm2-Disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  admin_username = var.username
  admin_password = var.password

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}

# Random Pet for unique naming
resource "random_pet" "prefix" {
  prefix = var.resource_group_name_prefix
  length = 1
}

# Random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}