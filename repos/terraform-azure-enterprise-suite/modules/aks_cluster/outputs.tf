output "cluster_id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "The Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL for Workload Identity."
  value       = try(azurerm_kubernetes_cluster.aks.oidc_issuer_url, null)
}

output "kube_config" {
  description = "Raw Kubernetes configuration (sensitive)."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Kubelet Managed Identity Object ID for Azure ACR pull role assignment."
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "node_pool_ids" {
  description = "Map of additional node pool names to their IDs."
  value       = { for k, v in azurerm_kubernetes_cluster_node_pool.user_pools : k => v.id }
}

