////////////////////////
// Local customization
////////////////////////

locals {
  flags = {
    aks_system_enabled = true
    aks_nodes_enabled  = false
    acr_enabled        = true
  }

  resource_group_suffix   = "AksModuleDemo"
  resource_group_location = "northeurope"

  network_address = "192.168.0.0/16"

  tags = {
    "module-url" = "kred-no/teraform-azurerm-aks"
  }
}

////////////////////////
// Non-Module Resources
////////////////////////

resource "random_string" "RESOURCE" {
  length  = 5
  special = false
  upper   = false

  keepers = {
    suffix = local.resource_group_suffix
  }
}

resource "azurerm_resource_group" "MAIN" {
  name     = join("-", [random_string.RESOURCE.result, random_string.RESOURCE.keepers.suffix])
  location = local.resource_group_location
}

resource "azurerm_virtual_network" "MAIN" {
  name                = "ExampleAksNetwork"
  address_space       = [local.network_address]
  resource_group_name = azurerm_resource_group.MAIN.name
  location            = azurerm_resource_group.MAIN.location
}

resource "azurerm_subnet" "SYSTEM_NODES" {
  name                 = "AksSystemSubnet"
  address_prefixes     = [cidrsubnet(local.network_address, 8, 0)]
  virtual_network_name = azurerm_virtual_network.MAIN.name
  resource_group_name  = azurerm_virtual_network.MAIN.resource_group_name
}

resource "azurerm_subnet" "USER_NODES" {
  name                 = "AksUserSubnet"
  address_prefixes     = [cidrsubnet(local.network_address, 8, 1)]
  virtual_network_name = azurerm_virtual_network.MAIN.name
  resource_group_name  = azurerm_virtual_network.MAIN.resource_group_name
}

////////////////////////
// Module
////////////////////////

module "CLUSTER" {
  count  = local.flags.aks_system_enabled ? 1 : 0
  source = "./../../../terraform-azurerm-aks"

  // Config
  default_pool_enabled       = local.flags.aks_system_enabled
  container_registry_enabled = local.flags.acr_enabled
  
  node_resource_group_name = format("%s-AksNodes", azurerm_resource_group.MAIN.name)

  // References
  tags           = local.tags
  resource_group = azurerm_resource_group.MAIN
  subnet         = azurerm_subnet.SYSTEM_NODES
}

////////////////////////
// Outputs
////////////////////////

output "kube_config" {
  sensitive = true
  value     = one(module.CLUSTER[*].kube_config)
}
