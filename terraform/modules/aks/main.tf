# Private cluster: the API server has no public IP/FQDN, reachable only from
# inside the VNet (or a peered network / VPN). This satisfies "cluster should
# be private". Ingress traffic to the *applications* is a separate concern -
# a Kubernetes Service of type LoadBalancer still gets a normal public
# Standard Load Balancer IP, independent of the private API server, which is
# how the end goal ("apps reachable on a public ingress IP") stays possible.
resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.dns_prefix
  kubernetes_version         = var.kubernetes_version
  private_cluster_enabled    = true
  private_dns_zone_id        = "System"
  sku_tier                   = "Free"
  tags                       = var.tags

  default_node_pool {
    name           = "system"
    vm_size        = var.node_vm_size
    node_count     = var.node_count
    vnet_subnet_id = var.aks_subnet_id
    os_disk_size_gb = 30
    type           = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "kubenet"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    pod_cidr           = var.pod_cidr
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
  }
}

# Lets kubelet pull from ACR without any stored registry credential.
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                             = var.acr_id
  role_definition_name              = "AcrPull"
  principal_id                      = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  skip_service_principal_aad_check  = true
}
