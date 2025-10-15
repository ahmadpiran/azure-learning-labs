terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.6"
    }
  }

  required_version = "~>1.13"
}

provider "azurerm" {
  features {}
}

provider "azuread" {}