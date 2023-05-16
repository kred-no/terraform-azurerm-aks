////////////////////////
// Example Configuration
////////////////////////

locals {
  prefix   = "AksMinimal"
  location = "NorthEurope"

  network_name  = "aks"
  address_space = ["192.168.0.0/24"]

  subnet = {
    prefixes = ["192.168.0.0/27"]
    rules = [{
      name                   = "22-ssh-allow"
      priority               = 500
      access                 = "Allow"
      direction              = "Inbound"
      destination_port_range = "22"
      source_port_range      = "*"
      source_address_prefix  = "*"
    }]
  }

  tags = {}
}

////////////////////////
// Module
////////////////////////

output "aks_admin" {
  sensitive = true
  value     = module.minimal-aks.aks_admin
}

output "aks" {
  sensitive = true
  value     = module.minimal-aks.aks
}

module "minimal-aks" {
  source = "../../../terraform-azurerm-aks"

  depends_on = [
    azurerm_resource_group.MAIN,
    azurerm_virtual_network.MAIN,
  ]

  subnet = local.subnet
  tags   = local.tags

  resource_group = azurerm_resource_group.MAIN
  network        = azurerm_virtual_network.MAIN
}

////////////////////////
// Root Resources
////////////////////////

resource "azurerm_virtual_network" "MAIN" {
  name          = local.network_name
  address_space = local.address_space

  resource_group_name = azurerm_resource_group.MAIN.name
  location            = azurerm_resource_group.MAIN.location
}

resource "azurerm_resource_group" "MAIN" {
  name     = join("-", [random_id.UNIQUE.keepers.prefix, random_id.UNIQUE.hex])
  location = random_id.UNIQUE.keepers.location
}

resource "random_id" "UNIQUE" {
  byte_length = 3

  keepers = {
    prefix   = local.prefix
    location = local.location
  }
}

////////////////////////
// Root Resources
////////////////////////

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}

  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

variable "tenant_id" {}
variable "subscription_id" {}