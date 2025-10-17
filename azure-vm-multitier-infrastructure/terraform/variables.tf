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