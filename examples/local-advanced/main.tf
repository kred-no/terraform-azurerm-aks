////////////////////////
// Local Configuration
////////////////////////

locals {
  flags = {
    system_pool_enabled = true
    user_pool_enabled   = false
    acr_enabled         = false
  }

  resource_group_suffix   = "DemoAksAdvanced"
  resource_group_location = "northeurope"

  network_name    = "ExampleAksNetwork"
  network_address = "192.168.0.0/16"

  tags = {
    "module-url" = "kred-no/teraform-azurerm-aks"
  }
}

resource "random_string" "RESOURCE" {
  length  = 5
  special = false
  upper   = false

  keepers = {
    suffix = local.resource_group_suffix
  }
}

////////////////////////
// ARM Core Resources
////////////////////////

resource "azurerm_resource_group" "MAIN" {
  name     = join("-", [random_string.RESOURCE.result, random_string.RESOURCE.keepers.suffix])
  location = local.resource_group_location
}

////////////////////////
// Networks
////////////////////////

resource "azurerm_virtual_network" "MAIN" {
  name          = local.network_name
  address_space = [local.network_address]
  
  resource_group_name = azurerm_resource_group.MAIN.name
  location            = azurerm_resource_group.MAIN.location
}

// Create 2 x subnets
resource "azurerm_subnet" "MAIN" {
  for_each = {
    "SystemNodeSubnet" = [cidrsubnet(local.network_address, 8, 0)]
    "UserNodeSubnet"   = [cidrsubnet(local.network_address, 8, 1)]
  }

  name             = each.key
  address_prefixes = each.value

  virtual_network_name = azurerm_virtual_network.MAIN.name
  resource_group_name  = azurerm_virtual_network.MAIN.resource_group_name
}

// Provide pre-created public IP for inbound/outbound traffic
resource "azurerm_public_ip" "MAIN" {
  name              = "cluster-public-ip"
  allocation_method = "Static"
  sku               = "Standard"

  tags                = local.tags
  resource_group_name = azurerm_virtual_network.MAIN.resource_group_name
  location            = azurerm_virtual_network.MAIN.location
}

////////////////////////
// Network Security
////////////////////////

resource "azurerm_network_security_group" "MAIN" {
  name = "cluster-nsg"

  resource_group_name = azurerm_virtual_network.MAIN.resource_group_name
  location            = azurerm_virtual_network.MAIN.location
}

// Add all aks subnets to same nsg
resource "azurerm_subnet_network_security_group_association" "MAIN" {
  for_each = azurerm_subnet.MAIN

  subnet_id                 = each.value["id"]
  network_security_group_id = azurerm_network_security_group.MAIN.id
}

////////////////////////
// Network Routing
////////////////////////

resource "azurerm_route_table" "MAIN" {
  name = "cluster-rtable"

  tags                = local.tags
  resource_group_name = azurerm_virtual_network.MAIN.resource_group_name
  location            = azurerm_virtual_network.MAIN.location
}

resource "azurerm_subnet_route_table_association" "MAIN" {
  for_each = azurerm_subnet.MAIN

  subnet_id      = each.value["id"]
  route_table_id = azurerm_route_table.MAIN.id
}

////////////////////////
// Private DNS
////////////////////////
// Only for private clusters

/*resource "azurerm_private_dns_zone" "MAIN" {
  name                = format("privatelink.%s.azmk8s.io", azurerm_virtual_network.MAIN.location)
  resource_group_name = azurerm_resource_group.MAIN.name
}*/

////////////////////////
// Module
////////////////////////

module "CLUSTER" {
  count  = 1
  source = "./../../../terraform-azurerm-aks"

  // Config
  node_resource_group_name   = format("%s-Nodes", azurerm_resource_group.MAIN.name)
  default_pool_enabled       = local.flags.system_pool_enabled
  container_registry_enabled = local.flags.acr_enabled
  container_registry_name    = format("acr%s", random_string.RESOURCE.result) // Globally Unique name required
  #private_dns_zone_id        = azurerm_private_dns_zone.MAIN.id // Private clusters only
  
  network_profile = {
    network_plugin = "azure"
    network_mode   = "transparent" // Required
    network_policy = "azure"
    
    load_balancer_profile = {
      outbound_ip_address_ids = [
        azurerm_public_ip.MAIN.id,
      ]
    }
  }

  auto_scaler_profile = {} // Use defaults

  maintenance_window = {
    allowed = [{
      day   = "Saturday"
      hours = [2, 3, 4, 5]
      }, {
      day   = "Sunday"
      hours = [2, 3, 4, 5]
    }]
  }

  default_node_pool = {
    vnet_subnet_id = azurerm_subnet.MAIN["SystemNodeSubnet"].id
    max_pods       = 64
    os_sku         = "Mariner"

    enable_auto_scaling = false

    upgrade_settings = {
      max_surge = 1
    }
  }

  node_pools = local.flags.user_pool_enabled ? [{
    name           = "userpool"
    vnet_subnet_id = azurerm_subnet.MAIN["UserNodeSubnet"].id
    max_pods       = 50
    os_sku         = "Mariner"

    enable_auto_scaling    = true
    auto_scaling_max_count = 2
    auto_scaling_min_count = 0

    upgrade_settings = {
      max_surge = 1
    }
  }] : []

  azure_ad_rbac = {
    managed            = true
    azure_rbac_enabled = true
    //admin_group_object_ids = []
  }

  // External References
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

output "az_auth" {
  sensitive = false

  value = format(
    "az aks get-credentials --resource-group %s --name %s",
    azurerm_resource_group.MAIN.name,
    one(module.CLUSTER[*].cluster_name),
  )
}