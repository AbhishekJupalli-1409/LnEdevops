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
  # Pin the managed RG name so it matches the policy not_scopes exemption.
  node_resource_group       = "MC_${var.resource_group_name}_${var.cluster_name}_${var.location}"

  # Azure enables this on current AKS versions. Once on, it cannot be turned
  # off (OIDCIssuerFeatureCannotBeDisabled). Terraform defaults it to false,
  # which breaks apply after import of an existing cluster.
  oidc_issuer_enabled = true

  default_node_pool {
    name           = "system"
    vm_size        = var.node_vm_size
    node_count     = var.node_count
    vnet_subnet_id = var.aks_subnet_id
    os_disk_size_gb = 30
    type           = "VirtualMachineScaleSets"
    # Apply the same tags as the cluster so the node VMSS is not denied by
    # the Require-a-tag policies if the MC_ RG exemption is slow/mismatched.
    tags           = var.tags
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

  lifecycle {
    # After import, Azure has a concrete version while config leaves this
    # null (let Azure pick). Ignore so we do not replace the cluster.
    ignore_changes = [kubernetes_version]
  }
}

# Lets kubelet pull from ACR without any stored registry credential.
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                             = var.acr_id
  role_definition_name              = "AcrPull"
  principal_id                      = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  skip_service_principal_aad_check  = true
}
