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