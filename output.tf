output "kube_config" {
  sensitive = true
  value     = one(azurerm_kubernetes_cluster.MAIN[*].kube_config_raw)
}

output "kube_admin_config" {
  sensitive = true
  value     = one(azurerm_kubernetes_cluster.MAIN[*].kube_admin_config_raw)
}

output "node_pools" {
  sensitive = false

  value = [
    azurerm_kubernetes_cluster_node_pool.MAIN,
  ]
}

output "user_identity" {
  description = "User Assigned Identity"
  sensitive   = false
  value       = azurerm_user_assigned_identity.MAIN
}

output "application_security_group" {
  sensitive = false
  value     = one(azurerm_application_security_group.MAIN[*])
}

output "route_table" {
  sensitive = false
  value     = azurerm_route_table.MAIN
}
