////////////////////////
// Local customization
////////////////////////

locals {
  resource_group_suffix   = "DemoAksBasic"
  resource_group_location = "northeurope"

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

////////////////////////
// Module
////////////////////////

module "CLUSTER" {
  count  = local.flags.aks_system_enabled ? 1 : 0
  source = "./../../../terraform-azurerm-aks"

  // Config
  node_resource_group_name = format("%s-AksNodes", azurerm_resource_group.MAIN.name)

  // References
  tags           = local.tags
  resource_group = azurerm_resource_group.MAIN
}

////////////////////////
// Outputs
////////////////////////

output "kube_config" {
  sensitive = true
  value     = one(module.CLUSTER[*].kube_config)
}

output "container_registry_url" {
  sensitive = false
  value     = one(module.CLUSTER[*].container_registry_url)
}
