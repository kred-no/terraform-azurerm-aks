////////////////////////
// Non-Module Resources
////////////////////////

data "azurerm_resource_group" "MAIN" {
  name = var.resource_group.name
}

data "azurerm_virtual_network" "MAIN" {
  name                = var.subnet.virtual_network_name
  resource_group_name = var.subnet.resource_group_name
}

data "azurerm_subnet" "MAIN" {
  name                 = var.subnet.name
  resource_group_name  = var.subnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.MAIN.name
}

data "azurerm_network_security_group" "MAIN" {
  count = var.network_security_group != null ? 1 : 0

  name                = var.network_security_group.name
  resource_group_name = var.network_security_group.resource_group_name
}

////////////////////////
// User Role Assignment
////////////////////////

resource "azurerm_user_assigned_identity" "MAIN" {
  name = join("-", [var.cluster_name, "identity"])

  resource_group_name = data.azurerm_resource_group.MAIN.name
  location            = data.azurerm_resource_group.MAIN.location
}

resource "azurerm_role_assignment" "MAIN" {
  for_each = toset([
    "Network Contributor",
    "Private DNS Zone Contributor",
  ])

  role_definition_name = each.value
  principal_id         = azurerm_user_assigned_identity.MAIN.principal_id
  scope                = data.azurerm_resource_group.MAIN.id
}

////////////////////////
// Network Security 
////////////////////////

resource "azurerm_application_security_group" "MAIN" {
  count = var.network_security_group != null ? 1 : 0

  name                = join("-", [data.azurerm_subnet.MAIN.name, "asg"])
  tags                = var.tags
  location            = data.azurerm_virtual_network.MAIN.location
  resource_group_name = data.azurerm_virtual_network.MAIN.name
}

resource "azurerm_network_security_rule" "MAIN" {
  for_each = {
    for rule in var.nsg_rules : rule.priority => rule
    if var.network_security_group != null
  }

  name        = each.value["name"]
  priority    = each.value["priority"]
  description = each.value["description"]
  protocol    = each.value["protocol"]
  access      = each.value["access"]
  direction   = each.value["direction"]

  source_port_range            = each.value["source_port_range"]
  source_port_ranges           = each.value["source_port_ranges"]
  source_address_prefix        = each.value["source_address_prefix"]
  source_address_prefixes      = each.value["source_address_prefixes"]
  destination_port_range       = each.value["destination_port_range"]
  destination_port_ranges      = each.value["destination_port_ranges"]
  destination_address_prefix   = each.value["destination_address_prefix"]
  destination_address_prefixes = each.value["destination_address_prefixes"]

  source_application_security_group_ids = flatten([
    each.value["source_application_security_group_ids"],
    anytrue([
      length(each.value["source_address_prefix"]) > 0,
      length(each.value["source_address_prefixes"]) > 0,
    ]) ? [] : [one(azurerm_application_security_group.MAIN[*].id)],
  ])

  destination_application_security_group_ids = flatten([
    each.value["destination_application_security_group_ids"],
    anytrue([
      length(each.value["destination_address_prefix"]) > 0,
      length(each.value["destination_address_prefixes"]) > 0,
    ]) ? [] : [one(azurerm_application_security_group.MAIN[*].id)],
  ])

  network_security_group_name = one(data.azurerm_network_security_group.MAIN[*].name)
  resource_group_name         = one(data.azurerm_network_security_group.MAIN[*].resource_group_name)
}

////////////////////////
// Network Routing
////////////////////////

resource "azurerm_route_table" "MAIN" {
  name = join("-", [var.cluster_name, "rtable"])

  tags                = var.tags
  resource_group_name = data.azurerm_virtual_network.MAIN.resource_group_name
  location            = data.azurerm_virtual_network.MAIN.location
}

resource "azurerm_subnet_route_table_association" "MAIN" {
  subnet_id      = data.azurerm_subnet.MAIN.id
  route_table_id = azurerm_route_table.MAIN.id
}

////////////////////////
// Aks Cluster
////////////////////////
// See "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#argument-reference"

resource "azurerm_kubernetes_cluster" "MAIN" {
  count = var.default_pool_enabled ? 1 : 0

  name                                = var.cluster_name
  dns_prefix                          = var.private_cluster_enabled ? null : var.dns_prefix
  dns_prefix_private_cluster          = var.private_cluster_enabled ? var.dns_prefix : null
  automatic_channel_upgrade           = var.automatic_channel_upgrade
  azure_policy_enabled                = var.azure_policy_enabled
  disk_encryption_set_id              = var.disk_encryption_set_id
  edge_zone                           = var.edge_zone
  http_application_routing_enabled    = var.http_application_routing_enabled
  image_cleaner_enabled               = var.image_cleaner_enabled
  image_cleaner_interval_hours        = var.image_cleaner_interval_hours
  kubernetes_version                  = var.kubernetes_version
  local_account_disabled              = var.local_account_disabled
  node_resource_group                 = var.node_resource_group_name
  oidc_issuer_enabled                 = var.oidc_issuer_enabled
  open_service_mesh_enabled           = var.open_service_mesh_enabled
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  workload_identity_enabled           = var.workload_identity_enabled
  public_network_access_enabled       = var.public_network_access_enabled
  role_based_access_control_enabled   = var.role_based_access_control_enabled
  run_command_enabled                 = var.run_command_enabled
  sku_tier                            = var.sku_tier

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.MAIN.id,
    ]
  }

  default_node_pool {
    name                          = var.default_node_pool.name
    vm_size                       = var.default_node_pool.vm_size
    capacity_reservation_group_id = var.default_node_pool.capacity_reservation_group_id
    custom_ca_trust_enabled       = var.default_node_pool.custom_ca_trust_enabled
    enable_auto_scaling           = var.default_node_pool.enable_auto_scaling
    enable_host_encryption        = var.default_node_pool.enable_host_encryption
    enable_node_public_ip         = var.default_node_pool.enable_node_public_ip
    host_group_id                 = var.default_node_pool.host_group_id
    fips_enabled                  = var.default_node_pool.fips_enabled
    kubelet_disk_type             = var.default_node_pool.kubelet_disk_type
    max_pods                      = var.default_node_pool.max_pods
    message_of_the_day            = var.default_node_pool.message_of_the_day
    node_public_ip_prefix_id      = var.default_node_pool.node_public_ip_prefix_id
    node_labels                   = var.default_node_pool.node_labels
    node_taints                   = var.default_node_pool.node_taints
    only_critical_addons_enabled  = var.default_node_pool.only_critical_addons_enabled
    orchestrator_version          = var.default_node_pool.orchestrator_version
    os_disk_size_gb               = var.default_node_pool.os_disk_size_gb
    os_disk_type                  = var.default_node_pool.os_disk_type
    os_sku                        = var.default_node_pool.os_sku
    pod_subnet_id                 = var.default_node_pool.pod_subnet_id
    proximity_placement_group_id  = var.default_node_pool.proximity_placement_group_id
    scale_down_mode               = var.default_node_pool.scale_down_mode
    temporary_name_for_rotation   = var.default_node_pool.temporary_name_for_rotation
    type                          = var.default_node_pool.type
    tags                          = var.default_node_pool.tags
    ultra_ssd_enabled             = var.default_node_pool.ultra_ssd_enabled
    vnet_subnet_id                = var.default_node_pool.vnet_subnet_id
    workload_runtime              = var.default_node_pool.workload_runtime
    zones                         = var.default_node_pool.zones
    max_count                     = var.default_node_pool.auto_scaling_max_count
    min_count                     = var.default_node_pool.auto_scaling_min_count
    node_count                    = var.default_node_pool.node_count

    dynamic "kubelet_config" {
      for_each = var.default_node_pool.kubelet_config[*]

      content {
        allowed_unsafe_sysctls    = kubelet_config.value["allowed_unsafe_sysctls"]
        container_log_max_line    = kubelet_config.value["container_log_max_line"]
        container_log_max_size_mb = kubelet_config.value["container_log_max_size_mb"]
        cpu_cfs_quota_enabled     = kubelet_config.value["cpu_cfs_quota_enabled"]
        cpu_cfs_quota_period      = kubelet_config.value["cpu_cfs_quota_period"]
        cpu_manager_policy        = kubelet_config.value["cpu_manager_policy"]
        image_gc_high_threshold   = kubelet_config.value["image_gc_high_threshold"]
        image_gc_low_threshold    = kubelet_config.value["image_gc_low_threshold"]
        pod_max_pid               = kubelet_config.value["pod_max_pid"]
        topology_manager_policy   = kubelet_config.value["topology_manager_policy"]
      }
    }

    dynamic "linux_os_config" {
      for_each = var.default_node_pool.linux_os_config[*]

      content {
        swap_file_size_mb             = linux_os_config.value["swap_file_size_mb"]
        transparent_huge_page_defrag  = linux_os_config.value["transparent_huge_page_defrag"]
        transparent_huge_page_enabled = linux_os_config.value["transparent_huge_page_enabled"]

        dynamic "sysctl_config" {
          for_each = linux_os_config.value["sysctl_config"][*]

          content {
            fs_aio_max_nr                      = sysctl_config.value["fs_aio_max_nr"]
            fs_file_max                        = sysctl_config.value["fs_file_max"]
            fs_inotify_max_user_watches        = sysctl_config.value["fs_inotify_max_user_watches"]
            fs_nr_open                         = sysctl_config.value["fs_nr_open"]
            kernel_threads_max                 = sysctl_config.value["kernel_threads_max"]
            net_core_netdev_max_backlog        = sysctl_config.value["net_core_netdev_max_backlog"]
            net_core_optmem_max                = sysctl_config.value["net_core_optmem_max"]
            net_core_rmem_default              = sysctl_config.value["net_core_rmem_default"]
            net_core_rmem_max                  = sysctl_config.value["net_core_rmem_max"]
            net_core_somaxconn                 = sysctl_config.value["net_core_somaxconn"]
            net_core_wmem_default              = sysctl_config.value["net_core_wmem_default"]
            net_core_wmem_max                  = sysctl_config.value["net_core_wmem_max"]
            net_ipv4_ip_local_port_range_max   = sysctl_config.value["net_ipv4_ip_local_port_range_max"]
            net_ipv4_ip_local_port_range_min   = sysctl_config.value["net_ipv4_ip_local_port_range_min"]
            net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value["net_ipv4_neigh_default_gc_thresh1"]
            net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value["net_ipv4_neigh_default_gc_thresh2"]
            net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value["net_ipv4_neigh_default_gc_thresh3"]
            net_ipv4_tcp_fin_timeout           = sysctl_config.value["net_ipv4_tcp_fin_timeout"]
            net_ipv4_tcp_keepalive_intvl       = sysctl_config.value["net_ipv4_tcp_keepalive_intvl"]
            net_ipv4_tcp_keepalive_probes      = sysctl_config.value["net_ipv4_tcp_keepalive_probes"]
            net_ipv4_tcp_keepalive_time        = sysctl_config.value["net_ipv4_tcp_keepalive_time"]
            net_ipv4_tcp_max_syn_backlog       = sysctl_config.value["net_ipv4_tcp_max_syn_backlog"]
            net_ipv4_tcp_max_tw_buckets        = sysctl_config.value["net_ipv4_tcp_max_tw_buckets"]
            net_ipv4_tcp_tw_reuse              = sysctl_config.value["net_ipv4_tcp_tw_reuse"]
            net_netfilter_nf_conntrack_buckets = sysctl_config.value["net_netfilter_nf_conntrack_buckets"]
            net_netfilter_nf_conntrack_max     = sysctl_config.value["net_netfilter_nf_conntrack_max"]
            vm_max_map_count                   = sysctl_config.value["vm_max_map_count"]
            vm_swappiness                      = sysctl_config.value["vm_swappiness"]
            vm_vfs_cache_pressure              = sysctl_config.value["vm_vfs_cache_pressure"]
          }
        }
      }
    }

    dynamic "node_network_profile" {
      for_each = var.default_node_pool.node_network_profile[*]

      content {
        node_public_ip_tags = node_network_profile.value["node_public_ip_tags"]
      }
    }

    dynamic "upgrade_settings" {
      for_each = var.default_node_pool.upgrade_settings[*]

      content {
        max_surge = upgrade_settings.value["max_surge"]
      }
    }
  }

  dynamic "aci_connector_linux" {
    for_each = var.aci_connector_linux[*]

    content {
      subnet_name = aci_connector_linux.value["subnet_name"]
    }
  }

  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile[*]

    content {
      authorized_ip_ranges     = api_server_access_profile.value["authorized_ip_ranges"]
      subnet_id                = api_server_access_profile.value["subnet_id"]
      vnet_integration_enabled = api_server_access_profile.value["vnet_integration_enabled"]
    }
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile[*]

    content {
      balance_similar_node_groups      = auto_scaler_profile.value["balance_similar_node_groups"]
      expander                         = auto_scaler_profile.value["expander"]
      max_graceful_termination_sec     = auto_scaler_profile.value["max_graceful_termination_sec"]
      max_node_provisioning_time       = auto_scaler_profile.value["max_node_provisioning_time"]
      max_unready_nodes                = auto_scaler_profile.value["max_unready_nodes"]
      max_unready_percentage           = auto_scaler_profile.value["max_unready_percentage"]
      new_pod_scale_up_delay           = auto_scaler_profile.value["new_pod_scale_up_delay"]
      scale_down_delay_after_add       = auto_scaler_profile.value["scale_down_delay_after_add"]
      scale_down_delay_after_delete    = auto_scaler_profile.value["scale_down_delay_after_delete"]
      scale_down_delay_after_failure   = auto_scaler_profile.value["scale_down_delay_after_failure"]
      scan_interval                    = auto_scaler_profile.value["scan_interval"]
      scale_down_unneeded              = auto_scaler_profile.value["scale_down_unneeded"]
      scale_down_unready               = auto_scaler_profile.value["scale_down_unready"]
      scale_down_utilization_threshold = auto_scaler_profile.value["scale_down_utilization_threshold"]
      empty_bulk_delete_max            = auto_scaler_profile.value["empty_bulk_delete_max"]
      skip_nodes_with_local_storage    = auto_scaler_profile.value["skip_nodes_with_local_storage"]
      skip_nodes_with_system_pods      = auto_scaler_profile.value["skip_nodes_with_system_pods"]
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_ad_rbac[*]

    content {
      managed                = azure_active_directory_role_based_access_control.value["managed"]
      tenant_id              = azure_active_directory_role_based_access_control.value["tenant_id"]
      admin_group_object_ids = azure_active_directory_role_based_access_control.value["admin_group_object_ids"]
      azure_rbac_enabled     = azure_active_directory_role_based_access_control.value["azure_rbac_enabled"]
      client_app_id          = azure_active_directory_role_based_access_control.value["client_app_id"]
      server_app_id          = azure_active_directory_role_based_access_control.value["server_app_id"]
      server_app_secret      = azure_active_directory_role_based_access_control.value["server_app_secret"]
    }
  }

  dynamic "confidential_computing" {
    for_each = var.confidential_computing[*]

    content {
      sgx_quote_helper_enabled = confidential_computing.value["sgx_quote_helper_enabled"]
    }
  }

  dynamic "http_proxy_config" {
    for_each = var.http_proxy_config[*]

    content {
      http_proxy  = http_proxy_config.value["http_proxy"]
      https_proxy = http_proxy_config.value["https_proxy"]
      no_proxy    = http_proxy_config.value["no_proxy"]
      trusted_ca  = http_proxy_config.value["trusted_ca"]
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway[*]

    content {
      gateway_id   = ingress_application_gateway.value["gateway_id"]
      gateway_name = ingress_application_gateway.value["gateway_name"]
      subnet_cidr  = ingress_application_gateway.value["subnet_cidr"]
      subnet_id    = ingress_application_gateway.value["subnet_id"]
    }
  }

  dynamic "key_management_service" {
    for_each = var.key_management_service[*]

    content {
      key_vault_key_id         = key_management_service.value["key_vault_key_id"]
      key_vault_network_access = key_management_service.value["key_vault_network_access"]
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider[*]

    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value["secret_rotation_enabled"]
      secret_rotation_interval = key_vault_secrets_provider.value["secret_rotation_interval"]
    }
  }

  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity[*]

    content {
      client_id                 = kubelet_identity.value["client_id"]
      object_id                 = kubelet_identity.value["object_id"]
      user_assigned_identity_id = kubelet_identity.value["user_assigned_identity_id"]
    }
  }

  dynamic "linux_profile" {
    for_each = var.linux_profile[*]

    content {
      admin_username = linux_profile.value["admin_username"]

      ssh_key {
        key_data = linux_profile.value["ssh_key"]
      }
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window[*]

    content {
      dynamic "allowed" {
        for_each = maintenance_window.value["allowed"]

        content {
          day   = allowed.value["day"]
          hours = allowed.value["hour"]
        }
      }

      dynamic "not_allowed" {
        for_each = maintenance_window.value["not_allowed"]

        content {
          end   = allowed.value["end"]
          start = allowed.value["start"]
        }
      }
    }
  }

  dynamic "oms_agent" {
    for_each = var.oms_agent[*]

    content {
      log_analytics_workspace_id      = oms_agent.value["log_analytics_workspace_id"]
      msi_auth_for_monitoring_enabled = oms_agent.value["msi_auth_for_monitoring_enabled"]
    }
  }

  dynamic "service_mesh_profile" {
    for_each = var.service_mesh_profile[*]
    content {
      mode = service_mesh_profile.value["mode"]
    }
  }

  dynamic "storage_profile" {
    for_each = var.storage_profile[*]
    content {
      blob_driver_enabled = storage_profile.value["blob_driver_enabled"]
      disk_driver_enabled = storage_profile.value["disk_driver_enabled"]
      disk_driver_version = storage_profile.value["disk_driver_version"]
    }
  }

  dynamic "web_app_routing" {
    for_each = var.web_app_routing[*]

    content {
      dns_zone_id = web_app_routing.value["dns_zone_id"]
    }
  }

  dynamic "windows_profile" {
    for_each = var.windows_profile[*]

    content {
      admin_username = windows_profile.value["admin_username"]
      admin_password = windows_profile.value["admin_password"]
      license        = windows_profile.value["license"]

      dynamic "gmsa" {
        for_each = windows_profile.value["gmsa"][*]
        content {
          dns_server  = gmsa.value["dns_server"]
          root_domain = gmsa.value["root_domain"]
        }
      }
    }
  }

  dynamic "workload_autoscaler_profile" {
    for_each = var.workload_autoscaler_profile[*]

    content {
      keda_enabled                    = workload_autoscaler_profile.value["keda_enabled"]
      vertical_pod_autoscaler_enabled = workload_autoscaler_profile.value["vertical_pod_autoscaler_enabled"]
    }
  }

  tags                = var.tags
  location            = data.azurerm_resource_group.MAIN.location
  resource_group_name = data.azurerm_resource_group.MAIN.name
}

////////////////////////
// Aks Node Pools
////////////////////////

resource "azurerm_kubernetes_cluster_node_pool" "MAIN" {
  for_each = toset(var.node_pools)

  name                          = each.value["name"]
  vm_size                       = each.value["vm_size"]
  node_count                    = each.value["node_count"]
  capacity_reservation_group_id = each.value["capacity_reservation_group_id"]
  custom_ca_trust_enabled       = each.value["custom_ca_trust_enabled"]
  enable_auto_scaling           = each.value["enable_auto_scaling"]
  enable_host_encryption        = each.value["enable_host_encryption"]
  enable_node_public_ip         = each.value["enable_node_public_ip"]
  eviction_policy               = each.value["eviction_policy"]
  host_group_id                 = each.value["host_group_id"]
  fips_enabled                  = each.value["fips_enabled"]
  kubelet_disk_type             = each.value["kubelet_disk_type"]
  max_pods                      = each.value["max_pods"]
  message_of_the_day            = each.value["message_of_the_day"]
  mode                          = each.value["mode"]
  node_labels                   = each.value["node_labels"]
  node_public_ip_prefix_id      = each.value["node_public_ip_prefix_id"]
  node_taints                   = each.value["node_taints"]
  orchestrator_version          = each.value["orchestrator_version"]
  os_disk_size_gb               = each.value["os_disk_size_gb"]
  os_disk_type                  = each.value["os_disk_type"]
  pod_subnet_id                 = each.value["pod_subnet_id"]
  os_sku                        = each.value["os_sku"]
  os_type                       = each.value["os_type"]
  priority                      = each.value["priority"]
  proximity_placement_group_id  = each.value["proximity_placement_group_id"]
  spot_max_price                = each.value["spot_max_price"]
  snapshot_id                   = each.value["snapshot_id"]
  scale_down_mode               = each.value["scale_down_mode"]
  ultra_ssd_enabled             = each.value["ultra_ssd_enabled"]
  vnet_subnet_id                = each.value["vnet_subnet_id"]
  zones                         = each.value["zones"]
  max_count                     = each.value["auto_scaling_max_count"]
  min_count                     = each.value["auto_scaling_min_count"]
  workload_runtime              = each.value["workload_runtime"]

  dynamic "kubelet_config" {
    for_each = var.default_node_pool.kubelet_config[*]

    content {
      allowed_unsafe_sysctls    = kubelet_config.value["allowed_unsafe_sysctls"]
      container_log_max_line    = kubelet_config.value["container_log_max_line"]
      container_log_max_size_mb = kubelet_config.value["container_log_max_size_mb"]
      cpu_cfs_quota_enabled     = kubelet_config.value["cpu_cfs_quota_enabled"]
      cpu_cfs_quota_period      = kubelet_config.value["cpu_cfs_quota_period"]
      cpu_manager_policy        = kubelet_config.value["cpu_manager_policy"]
      image_gc_high_threshold   = kubelet_config.value["image_gc_high_threshold"]
      image_gc_low_threshold    = kubelet_config.value["image_gc_low_threshold"]
      pod_max_pid               = kubelet_config.value["pod_max_pid"]
      topology_manager_policy   = kubelet_config.value["topology_manager_policy"]
    }
  }

  dynamic "linux_os_config" {
    for_each = var.default_node_pool.linux_os_config[*]

    content {
      swap_file_size_mb             = linux_os_config.value["swap_file_size_mb"]
      transparent_huge_page_defrag  = linux_os_config.value["transparent_huge_page_defrag"]
      transparent_huge_page_enabled = linux_os_config.value["transparent_huge_page_enabled"]

      dynamic "sysctl_config" {
        for_each = linux_os_config.value["sysctl_config"][*]

        content {
          fs_aio_max_nr                      = sysctl_config.value["fs_aio_max_nr"]
          fs_file_max                        = sysctl_config.value["fs_file_max"]
          fs_inotify_max_user_watches        = sysctl_config.value["fs_inotify_max_user_watches"]
          fs_nr_open                         = sysctl_config.value["fs_nr_open"]
          kernel_threads_max                 = sysctl_config.value["kernel_threads_max"]
          net_core_netdev_max_backlog        = sysctl_config.value["net_core_netdev_max_backlog"]
          net_core_optmem_max                = sysctl_config.value["net_core_optmem_max"]
          net_core_rmem_default              = sysctl_config.value["net_core_rmem_default"]
          net_core_rmem_max                  = sysctl_config.value["net_core_rmem_max"]
          net_core_somaxconn                 = sysctl_config.value["net_core_somaxconn"]
          net_core_wmem_default              = sysctl_config.value["net_core_wmem_default"]
          net_core_wmem_max                  = sysctl_config.value["net_core_wmem_max"]
          net_ipv4_ip_local_port_range_max   = sysctl_config.value["net_ipv4_ip_local_port_range_max"]
          net_ipv4_ip_local_port_range_min   = sysctl_config.value["net_ipv4_ip_local_port_range_min"]
          net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value["net_ipv4_neigh_default_gc_thresh1"]
          net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value["net_ipv4_neigh_default_gc_thresh2"]
          net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value["net_ipv4_neigh_default_gc_thresh3"]
          net_ipv4_tcp_fin_timeout           = sysctl_config.value["net_ipv4_tcp_fin_timeout"]
          net_ipv4_tcp_keepalive_intvl       = sysctl_config.value["net_ipv4_tcp_keepalive_intvl"]
          net_ipv4_tcp_keepalive_probes      = sysctl_config.value["net_ipv4_tcp_keepalive_probes"]
          net_ipv4_tcp_keepalive_time        = sysctl_config.value["net_ipv4_tcp_keepalive_time"]
          net_ipv4_tcp_max_syn_backlog       = sysctl_config.value["net_ipv4_tcp_max_syn_backlog"]
          net_ipv4_tcp_max_tw_buckets        = sysctl_config.value["net_ipv4_tcp_max_tw_buckets"]
          net_ipv4_tcp_tw_reuse              = sysctl_config.value["net_ipv4_tcp_tw_reuse"]
          net_netfilter_nf_conntrack_buckets = sysctl_config.value["net_netfilter_nf_conntrack_buckets"]
          net_netfilter_nf_conntrack_max     = sysctl_config.value["net_netfilter_nf_conntrack_max"]
          vm_max_map_count                   = sysctl_config.value["vm_max_map_count"]
          vm_swappiness                      = sysctl_config.value["vm_swappiness"]
          vm_vfs_cache_pressure              = sysctl_config.value["vm_vfs_cache_pressure"]
        }
      }
    }
  }

  dynamic "node_network_profile" {
    for_each = each.value["node_network_profile"][*]

    content {
      node_public_ip_tags = node_network_profile.value["node_public_ip_tags"]
    }
  }

  dynamic "upgrade_settings" {
    for_each = each.value["upgrade_settings"][*]

    content {
      max_surge = upgrade_settings.value["max_surge"]
    }
  }

  dynamic "windows_profile" {
    for_each = each.value["windows_profile"][*]

    content {
      outbound_nat_enabled = windows_profile.value["outbound_nat_enabled"]
    }
  }

  tags                  = var.tags
  kubernetes_cluster_id = try(each.value["cluster_id"], one(azurerm_kubernetes_cluster.MAIN[*].id))
}

////////////////////////
// Container Registry
////////////////////////

resource "azurerm_container_registry" "MAIN" {
  count = var.container_registry_enabled ? 1 : 0

  name          = var.container_registry.name
  sku           = var.container_registry.sku
  admin_enabled = var.container_registry.admin_enabled

  dynamic "identity" {
    for_each = var.container_registry.identity[*]

    content {
      type         = identity.value["type"]
      identity_ids = identity.value["identity_ids"]
    }
  }

  dynamic "georeplications" {
    for_each = var.container_registry.georeplications

    content {
      location                  = georeplications.value["location"]
      regional_endpoint_enabled = georeplications.value["regional_endpoint_enabled"]
      zone_redundancy_enabled   = georeplications.value["zone_redundancy_enabled"]
      tags                      = georeplications.value["tags"]
    }
  }

  dynamic "network_rule_set" {
    for_each = var.container_registry.network_rule_set[*]

    content {
      default_action = network_rule_set.value["default_action"]

      dynamic "ip_rule" {
        for_each = network_rule_set.value["ip_rule"]

        content {
          action   = ip_rule.value["action"]
          ip_range = ip_rule.value["ip_range"]
        }
      }

      dynamic "virtual_network" {
        for_each = network_rule_set.value["virtual_network"]

        content {
          action    = virtual_network.value["action"]
          subnet_id = virtual_network.value["subnet_id"]
        }
      }
    }
  }

  dynamic "retention_policy" {
    for_each = var.container_registry.retention_policy[*]

    content {
      days    = retention_policy.value["days"]
      enabled = retention_policy.value["enabled"]
    }
  }

  dynamic "trust_policy" {
    for_each = var.container_registry.trust_policy[*]

    content {
      enabled = trust_policy.value["enabled"]
    }
  }

  dynamic "encryption" {
    for_each = var.container_registry.encryption[*]

    content {
      enabled            = encryption.value["enabled"]
      key_vault_key_id   = encryption.value["key_vault_key_id"]
      identity_client_id = encryption.value["identity_client_id"]
    }
  }

  tags                = var.tags
  resource_group_name = data.azurerm_resource_group.MAIN.name
  location            = data.azurerm_resource_group.MAIN.location
}

resource "azurerm_role_assignment" "ACR" {
  for_each = {
    for registry in azurerm_container_registry.MAIN: registry.name => registry.id
  }

  role_definition_name             = "AcrPull"
  scope                            = each.value
  principal_id                     = one(azurerm_kubernetes_cluster.MAIN[*].kubelet_identity[0].object_id)
  skip_service_principal_aad_check = true
}
