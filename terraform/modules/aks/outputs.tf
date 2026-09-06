output "cluster_id"           { value = azurerm_kubernetes_cluster.this.id }
output "cluster_name"         { value = azurerm_kubernetes_cluster.this.name }
output "node_resource_group"  { value = azurerm_kubernetes_cluster.this.node_resource_group }
output "private_fqdn"         { value = azurerm_kubernetes_cluster.this.private_fqdn }
output "kube_admin_config_raw" {
  value     = azurerm_kubernetes_cluster.this.kube_admin_config_raw
  sensitive = true
}
output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive = true
}
output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
