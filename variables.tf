////////////////////////
// Core
////////////////////////

variable "resource_group" {
  description = ""

  type = object({
    name     = string
    location = string
  })
}

variable "tags" {
  description = ""
  type        = map(string)

  default = {}
}

////////////////////////
// Aks System
////////////////////////

variable "cluster_name" {
  type    = string
  default = "aks-system"
}

variable "dns_prefix" {
  type    = string
  default = "aks"
}

variable "automatic_channel_upgrade" {
  type    = string
  default = null
}

variable "azure_policy_enabled" {
  type    = bool
  default = null
}

variable "disk_encryption_set_id" {
  type    = string
  default = null
}

variable "edge_zone" {
  type    = string
  default = null
}

variable "http_application_routing_enabled" {
  type    = bool
  default = null
}

variable "image_cleaner_enabled" {
  description = "Preview Feature"

  type    = bool
  default = null
}

variable "image_cleaner_interval_hours" {
  description = "Preview Feature"

  type    = number
  default = null
}

variable "kubernetes_version" {
  type    = string
  default = null // 1.26
}

variable "linux_profile" {
  type = object({
    admin_username = string
    ssh_key        = string
  })

  default = null
}

variable "local_account_disabled" {
  type    = bool
  default = null
}

variable "node_resource_group_name" {
  type    = string
  default = null
}

variable "oidc_issuer_enabled" {
  type    = bool
  default = null
}

variable "open_service_mesh_enabled" {
  type    = bool
  default = null
}

variable "private_cluster_enabled" {
  type    = bool
  default = false
}

variable "private_dns_zone_id" {
  type    = string
  default = null
}

variable "private_cluster_public_fqdn_enabled" {
  type    = bool
  default = null
}

variable "workload_identity_enabled" {
  description = "Preview Feature"

  type    = bool
  default = null
}

variable "public_network_access_enabled" {
  type    = bool
  default = null
}

variable "role_based_access_control_enabled" {
  type    = bool
  default = null
}

variable "run_command_enabled" {
  type    = bool
  default = null
}

variable "sku_tier" {
  type    = string
  default = null
}

variable "maintenance_window" {
  type = object({
    allowed = optional(list(object({
      day   = string
      hours = list(number)
    })), [])

    not_allowed = optional(list(object({
      end   = string // RFC3339 string
      start = string // RFC3339 string
    })), [])
  })

  default = null
}

variable "windows_profile" {
  type = object({
    admin_username = string
    admin_password = optional(string)
    license        = optional(string)

    gmsa = optional(object({
      dns_server  = string
      root_domain = string
    }), null)
  })

  default = null
}

variable "kubelet_identity" {
  type = object({
    client_id                 = optional(string)
    object_id                 = optional(string)
    user_assigned_identity_id = optional(string)
  })

  default = null
}

variable "auto_scaler_profile" {
  type = object({
    balance_similar_node_groups      = optional(bool)
    expander                         = optional(string)
    max_graceful_termination_sec     = optional(number)
    max_node_provisioning_time       = optional(string)
    max_unready_nodes                = optional(number)
    max_unready_percentage           = optional(number)
    new_pod_scale_up_delay           = optional(string)
    scale_down_delay_after_add       = optional(string)
    scale_down_delay_after_delete    = optional(string)
    scale_down_delay_after_failure   = optional(string)
    scan_interval                    = optional(string)
    scale_down_unneeded              = optional(string)
    scale_down_unready               = optional(string)
    scale_down_utilization_threshold = optional(number)
    empty_bulk_delete_max            = optional(number)
    skip_nodes_with_local_storage    = optional(bool)
    skip_nodes_with_system_pods      = optional(bool)
  })

  default = null
}

variable "http_proxy_config" {
  type = object({
    http_proxy  = optional(string)
    https_proxy = optional(string)
    no_proxy    = optional(list(string))
    trusted_ca  = optional(string)
  })

  default = null
}

variable "azure_ad_rbac" {
  type = object({
    managed                = optional(string)
    tenant_id              = optional(string)
    admin_group_object_ids = optional(list(string))
    azure_rbac_enabled     = optional(bool)
    client_app_id          = optional(string)
    server_app_id          = optional(string)
    server_app_secret      = optional(string)
  })

  default = null
}

variable "oms_agent" {
  type = object({
    log_analytics_workspace_id      = string
    msi_auth_for_monitoring_enabled = optional(bool)
  })

  default = null
}

variable "ingress_application_gateway" {
  type = object({
    gateway_id   = optional(string)
    gateway_name = optional(string)
    subnet_cidr  = optional(string)
    subnet_id    = optional(string)
  })

  default = null
}

variable "service_mesh_profile" {
  type = object({
    mode = optional(string, "Istio")
  })

  default = null
}

variable "storage_profile" {
  type = object({
    blob_driver_enabled = optional(bool)
    disk_driver_enabled = optional(bool)
    disk_driver_version = optional(string)
  })

  default = null
}

variable "web_app_routing" {
  type = object({
    dns_zone_id = string
  })

  default = null
}

variable "aci_connector_linux" {
  type = object({
    subnet_name = string
  })

  default = null
}

variable "api_server_access_profile" {
  type = object({
    authorized_ip_ranges     = optional(list(string))
    subnet_id                = optional(string)
    vnet_integration_enabled = optional(bool)
  })

  default = null
}

variable "key_management_service" {
  type = object({
    key_vault_key_id         = string
    key_vault_network_access = optional(string)
  })

  default = null
}

variable "key_vault_secrets_provider" {
  type = object({
    secret_rotation_enabled  = optional(bool)
    secret_rotation_interval = optional(string)
  })

  default = null
}

variable "confidential_computing" {
  type = object({
    sgx_quote_helper_enabled = bool
  })

  default = null
}

variable "workload_autoscaler_profile" {
  type = object({
    keda_enabled                    = optional(bool)
    vertical_pod_autoscaler_enabled = optional(bool)
  })

  default = null
}

variable "network_profile" {
  type = object({
    network_plugin      = string
    network_mode        = optional(string)
    network_policy      = optional(string)
    dns_service_ip      = optional(string)
    docker_bridge_cidr  = optional(string)
    ebpf_data_plane     = optional(string)
    network_plugin_mode = optional(string)
    outbound_type       = optional(string)
    pod_cidr            = optional(string)
    pod_cidrs           = optional(list(string))
    service_cidr        = optional(string)
    service_cidrs       = optional(list(string))
    ip_versions         = optional(list(string))
    load_balancer_sku   = optional(string)

    load_balancer_profile = optional(object({
      idle_timeout_in_minutes     = optional(number)
      managed_outbound_ip_count   = optional(number)
      managed_outbound_ipv6_count = optional(number)
      outbound_ip_address_ids     = optional(list(string))
      outbound_ip_prefix_ids      = optional(list(string))
      outbound_ports_allocated    = optional(number)
    }), null)

    nat_gateway_profile = optional(object({
      idle_timeout_in_minutes   = optional(number)
      managed_outbound_ip_count = optional(number)
    }), null)
  })

  default = null
}

////////////////////////
// Default Node Pool (System)
////////////////////////

variable "default_pool_enabled" {
  type    = bool
  default = true
}

variable "default_node_pool" {
  type = object({
    name       = optional(string, "agentpool")
    vm_size    = optional(string, "Standard_DS2_v2")
    node_count = optional(number, 1)

    capacity_reservation_group_id = optional(string)
    custom_ca_trust_enabled       = optional(bool)
    enable_auto_scaling           = optional(bool)
    enable_host_encryption        = optional(bool)
    enable_node_public_ip         = optional(bool)
    host_group_id                 = optional(string)
    fips_enabled                  = optional(bool)
    kubelet_disk_type             = optional(string)
    max_pods                      = optional(number)
    message_of_the_day            = optional(string)
    node_labels                   = optional(map(string))
    node_public_ip_prefix_id      = optional(string)
    node_taints                   = optional(list(string))
    only_critical_addons_enabled  = optional(bool)
    orchestrator_version          = optional(string)
    os_disk_size_gb               = optional(number)
    os_disk_type                  = optional(string)
    os_sku                        = optional(string)
    pod_subnet_id                 = optional(string)
    proximity_placement_group_id  = optional(string)
    scale_down_mode               = optional(string)
    temporary_name_for_rotation   = optional(string)
    type                          = optional(string)
    tags                          = optional(map(string))
    ultra_ssd_enabled             = optional(bool)
    vnet_subnet_id                = optional(string)
    workload_runtime              = optional(string)
    zones                         = optional(list(string))
    auto_scaling_max_count        = optional(number)
    auto_scaling_min_count        = optional(number)

    kubelet_config = optional(object({
      allowed_unsafe_sysctls    = optional(list(string))
      container_log_max_line    = optional(number)
      container_log_max_size_mb = optional(number)
      cpu_cfs_quota_enabled     = optional(bool)
      cpu_cfs_quota_period      = optional(number)
      cpu_manager_policy        = optional(string)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      pod_max_pid               = optional(number)
      topology_manager_policy   = optional(string)
    }), null)

    linux_os_config = optional(object({
      swap_file_size_mb             = optional(number)
      transparent_huge_page_defrag  = optional(string)
      transparent_huge_page_enabled = optional(bool)
      sysctl_config = optional(object({
        fs_aio_max_nr                      = optional(number)
        fs_file_max                        = optional(number)
        fs_inotify_max_user_watches        = optional(number)
        fs_nr_open                         = optional(number)
        kernel_threads_max                 = optional(number)
        net_core_netdev_max_backlog        = optional(number)
        net_core_optmem_max                = optional(number)
        net_core_rmem_default              = optional(number)
        net_core_rmem_max                  = optional(number)
        net_core_somaxconn                 = optional(number)
        net_core_wmem_default              = optional(number)
        net_core_wmem_max                  = optional(number)
        net_ipv4_ip_local_port_range_max   = optional(number)
        net_ipv4_ip_local_port_range_min   = optional(number)
        net_ipv4_neigh_default_gc_thresh1  = optional(number)
        net_ipv4_neigh_default_gc_thresh2  = optional(number)
        net_ipv4_neigh_default_gc_thresh3  = optional(number)
        net_ipv4_tcp_fin_timeout           = optional(number)
        net_ipv4_tcp_keepalive_intvl       = optional(number)
        net_ipv4_tcp_keepalive_probes      = optional(number)
        net_ipv4_tcp_keepalive_time        = optional(number)
        net_ipv4_tcp_max_syn_backlog       = optional(number)
        net_ipv4_tcp_max_tw_buckets        = optional(number)
        net_ipv4_tcp_tw_reuse              = optional(number)
        net_netfilter_nf_conntrack_buckets = optional(number)
        net_netfilter_nf_conntrack_max     = optional(number)
        vm_max_map_count                   = optional(number)
        vm_swappiness                      = optional(number)
        vm_vfs_cache_pressure              = optional(number)
      }), null)
    }), null)

    node_network_profile = optional(object({
      node_public_ip_tags = map(string)
    }), null)

    upgrade_settings = optional(object({
      max_surge = optional(number)
    }), null)
  })

  default = {}
}

////////////////////////
// Node Pools
////////////////////////

variable "node_pools" {
  type = list(object({
    name       = string
    mode       = optional(string, "User")
    vm_size    = optional(string, "Standard_DS2_v2")
    node_count = optional(number, 1)

    capacity_reservation_group_id = optional(string)
    custom_ca_trust_enabled       = optional(bool)
    enable_auto_scaling           = optional(bool)
    enable_host_encryption        = optional(bool)
    enable_node_public_ip         = optional(bool)
    eviction_policy               = optional(string)
    host_group_id                 = optional(string)
    fips_enabled                  = optional(bool)
    kubelet_disk_type             = optional(string)
    max_pods                      = optional(number)
    message_of_the_day            = optional(string)
    node_labels                   = optional(map(string))
    node_public_ip_prefix_id      = optional(string)
    node_taints                   = optional(list(string))
    orchestrator_version          = optional(string)
    os_disk_size_gb               = optional(number)
    os_disk_type                  = optional(string)
    pod_subnet_id                 = optional(string)
    os_sku                        = optional(string)
    os_type                       = optional(string)
    priority                      = optional(string)
    proximity_placement_group_id  = optional(string)
    spot_max_price                = optional(number)
    snapshot_id                   = optional(string)
    scale_down_mode               = optional(string)
    ultra_ssd_enabled             = optional(bool)
    vnet_subnet_id                = optional(string)
    zones                         = optional(list(string))
    auto_scaling_max_count        = optional(number)
    auto_scaling_min_count        = optional(number)
    workload_runtime              = optional(string)
    cluster_id                    = optional(string)

    kubelet_config = optional(object({
      allowed_unsafe_sysctls    = optional(list(string))
      container_log_max_line    = optional(number)
      container_log_max_size_mb = optional(number)
      cpu_cfs_quota_enabled     = optional(bool)
      cpu_cfs_quota_period      = optional(number)
      cpu_manager_policy        = optional(string)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      pod_max_pid               = optional(number)
      topology_manager_policy   = optional(string)
    }), null)

    linux_os_config = optional(object({
      swap_file_size_mb             = optional(number)
      transparent_huge_page_defrag  = optional(string)
      transparent_huge_page_enabled = optional(bool)

      sysctl_config = optional(object({
        fs_aio_max_nr                      = optional(number)
        fs_file_max                        = optional(number)
        fs_inotify_max_user_watches        = optional(number)
        fs_nr_open                         = optional(number)
        kernel_threads_max                 = optional(number)
        net_core_netdev_max_backlog        = optional(number)
        net_core_optmem_max                = optional(number)
        net_core_rmem_default              = optional(number)
        net_core_rmem_max                  = optional(number)
        net_core_somaxconn                 = optional(number)
        net_core_wmem_default              = optional(number)
        net_core_wmem_max                  = optional(number)
        net_ipv4_ip_local_port_range_max   = optional(number)
        net_ipv4_ip_local_port_range_min   = optional(number)
        net_ipv4_neigh_default_gc_thresh1  = optional(number)
        net_ipv4_neigh_default_gc_thresh2  = optional(number)
        net_ipv4_neigh_default_gc_thresh3  = optional(number)
        net_ipv4_tcp_fin_timeout           = optional(number)
        net_ipv4_tcp_keepalive_intvl       = optional(number)
        net_ipv4_tcp_keepalive_probes      = optional(number)
        net_ipv4_tcp_keepalive_time        = optional(number)
        net_ipv4_tcp_max_syn_backlog       = optional(number)
        net_ipv4_tcp_max_tw_buckets        = optional(number)
        net_ipv4_tcp_tw_reuse              = optional(number)
        net_netfilter_nf_conntrack_buckets = optional(number)
        net_netfilter_nf_conntrack_max     = optional(number)
        vm_max_map_count                   = optional(number)
        vm_swappiness                      = optional(number)
        vm_vfs_cache_pressure              = optional(number)
      }), null)
    }), null)

    node_network_profile = optional(object({
      node_public_ip_tags = optional(map(string))
    }), null)

    upgrade_settings = optional(object({
      max_surge = optional(number)
    }), null)

    windows_profile = optional(object({
      outbound_nat_enabled = optional(bool)
    }), null)
  }))

  default = []
}

////////////////////////
// Container Registry
////////////////////////

variable "container_registry_enabled" {
  type    = bool
  default = false
}

variable "container_registry_name" {
  description = "Globally unique name required."
  type        = string
  default     = null
}

variable "container_registry" {
  type = object({
    sku                           = optional(string, "Basic")
    admin_enabled                 = optional(bool)
    public_network_access_enabled = optional(bool)
    quarantine_policy_enabled     = optional(bool)
    zone_redundancy_enabled       = optional(bool)
    export_policy_enabled         = optional(bool)
    anonymous_pull_enabled        = optional(bool)
    data_endpoint_enabled         = optional(bool)
    network_rule_bypass_option    = optional(string)


    georeplications = optional(list(object({
      location                  = string
      regional_endpoint_enabled = optional(bool)
      zone_redundancy_enabled   = optional(bool)
      tags                      = optional(map(string))
    })), [])

    network_rule_set = optional(object({
      default_action = optional(string)

      ip_rule = optional(list(object({
        action   = string
        ip_range = string
      })), [])

      virtual_network = optional(list(object({
        action    = string
        subnet_id = string
      })), [])
    }), null)

    retention_policy = optional(object({
      days    = optional(number)
      enabled = optional(bool)
    }), null)

    trust_policy = optional(object({
      enabled = optional(bool)
    }), null)

    identity = optional(object({
      type         = optional(string, "SystemAssigned")
      identity_ids = optional(list(string), [])
    }), {})

    encryption = optional(object({
      enabled            = optional(bool)
      key_vault_key_id   = string
      identity_client_id = string
    }), null)

  })

  default = {}
}

variable "container_registry_role" {
  description = "See 'https://learn.microsoft.com/en-us/azure/container-registry/container-registry-roles'"
  type        = string
  default     = "AcrPull"
}
