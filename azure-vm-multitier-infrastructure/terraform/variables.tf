variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-vminfra-lab-dev"
}

variable "location" {
  description = "Azure region"
  default     = "francecentral"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

# Subnet CIDR Blocks
variable "subnet_web_cidr" {
  description = "CIDR block for web subnet (public-facing)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_app_cidr" {
  description = "CIDR block for App subnet (private)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_data_cidr" {
  description = "CIDR block for Data subnet (most restricted)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "subnet_mgmt_cidr" {
  description = "CIDR block for Management subnet (bastion)"
  type        = string
  default     = "10.0.10.0/24"
}

# My public IP for Bastion Access
variable "admin_source_ip" {
  description = "My Public IP address for SSH access to bastion (CIDR notation)"
  type        = string
  sensitive   = true
  # curl ifconfig.me
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B1s"
}

variable "data_disk_size_gb" {
  description = "Size of the data disk in GB"
  type        = number
  default     = 32
}

variable "data_disk_type" {
  description = "Type of managed disk (Standard_LRS, Premium_LRS, StandardSSD_LRS)"
  type        = string
  default     = "Standard_LRS"
}

# ============================================
# Bastion Host Configuration
# ============================================

variable "bastion_vm_size" {
  description = "VM size for bastion host (can be smaller)"
  type        = string
  default     = "Standard_b1s"
}

variable "bastion_vm_name" {
  description = "Name of the bastion VM"
  type        = string
  default     = "vm-vminfra-bastion-001"
}

# ============================================
# Application Tier Variables
# ============================================

variable "app_vm_name" {
  description = "Name of the application tier VM"
  type        = string
  default     = "vm-vminfra-app-001"
}

variable "app_vm_size" {
  description = "Size of the application VM"
  type        = string
  default     = "Standard_B1s"
}