resource "azurerm_kubernetes_cluster" "this" {
  name                    = var.cluster_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix
  kubernetes_version      = var.kubernetes_version
  private_cluster_enabled = true
  private_dns_zone_id     = "System"
  sku_tier                = "Free"
  tags                    = var.tags
  node_resource_group     = "MC_${var.resource_group_name}_${var.cluster_name}_${var.location}"
  oidc_issuer_enabled     = true

  default_node_pool {
    name           = "agentpool"
    vm_size        = var.node_vm_size
    node_count     = var.node_count
    vnet_subnet_id = var.aks_subnet_id
    type           = "VirtualMachineScaleSets"
    tags           = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
    pod_cidr          = var.pod_cidr
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  lifecycle {
    ignore_changes = [kubernetes_version, default_node_pool]
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = var.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}
