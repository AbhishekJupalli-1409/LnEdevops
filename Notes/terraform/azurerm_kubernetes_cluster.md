# azurerm_kubernetes_cluster

## Brief introduction

**AKS** is managed Kubernetes: Azure runs the control plane; you run workloads on node pools.

## Why we create it

Host employee frontend and todolist with GitOps, plus ingress-nginx for a public path-based entrypoint — while keeping the **API server private**.

## How Terraform creates it

```hcl
resource "azurerm_kubernetes_cluster" "this" {
  name                     = var.cluster_name
  private_cluster_enabled  = true
  private_dns_zone_id      = "System"
  sku_tier                 = "Free"

  default_node_pool {
    name           = "system"
    vnet_subnet_id = var.aks_subnet_id
    # ...
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}
```

Module: `terraform/modules/aks`.

## Use in this project

Private cluster for Flux-managed apps. Ingress still can get a **public** LB IP for `/emp` and `/to-do`.

## Example to understand

The Kubernetes “admin desk” (API) is inside a locked room (private). Customers still enter through the front door (ingress LoadBalancer) to use the apps.
