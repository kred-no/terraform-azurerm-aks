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

output "container_registry_url" {
  sensitive = false
  value     = one(azurerm_container_registry.MAIN[*].login_server)
}

output "cluster_name" {
  sensitive = false
  value     = one(azurerm_kubernetes_cluster.MAIN[*].name)
}
