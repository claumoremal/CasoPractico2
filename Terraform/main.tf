//En este fichero se define la configuración de terraform para trabajar con el provider Azure

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.66.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}