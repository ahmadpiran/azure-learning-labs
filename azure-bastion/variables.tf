variable "subscription_id" {
  type        = string
  description = "Enter subscription id in cmd"
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "AzureBastionRG"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "resource_group_location" {
  type        = string
  default     = "francecentral"
  description = "Location of the resource group"
}

variable "username" {
  type        = string
  default     = "azureuser"
  description = "Admin username for the VM"
}

variable "password" {
  type        = string
  default     = "A1s2d3f4g5!"
  description = "Admin password for the VM"
  sensitive   = true
}