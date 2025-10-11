# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = random_pet.prefix.id
  location = var.resource_group_location
}

# Virtual Network
resource "azurerm_virtual_network" "my_terraform_vnet" {
  name                = "${random_pet.prefix.id}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Bastion Subnet 
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP for Azure Bastion
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "${random_pet.prefix.id}-bastion-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Bastion subnet network security group
resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "${random_pet.prefix.id}-bastion-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Inbound Rules
  security_rule {
    name                       = "AllowGatewayManagerInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "GatewayManager"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "443"
  }

  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "443"
  }

  security_rule {
    name                       = "AllowBastionHostCommunicationInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges    = ["8080", "5701"]
  }

  # Outbound Rules
  security_rule {
    name                       = "AllowSshRdpOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges    = ["22", "3389"]
  }

  security_rule {
    name                       = "AllowAzureCloudOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "AzureCloud"
    destination_port_range     = "443"
  }

  security_rule {
    name                       = "AllowBastionCommunicationOutbound"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges    = ["8080", "5701"]
  }

  security_rule {
    name                       = "AllowHttpOutbound"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "Internet"
    destination_port_range     = "80"
  }
}


# Associate NSG to Bastion Subnet
resource "azurerm_subnet_network_security_group_association" "bastion_nsg_association" {
  subnet_id                 = azurerm_subnet.bastion_subnet.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
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

# VM Subnet
resource "azurerm_subnet" "vm_subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Interface for VM 1
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
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
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]

  location = azurerm_resource_group.rg.location
  size     = "Standard_D2s_v3"

  os_disk {
    name                 = "myOsDisk"
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
