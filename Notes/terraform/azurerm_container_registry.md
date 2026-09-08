# azurerm_container_registry

## Brief introduction

**ACR** stores Docker/OCI images. AKS and ACI pull app images from it.

## Why we create it

Central private registry for frontend, backend, and todolist images built by pipelines.

## How Terraform creates it

```hcl
resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}
```

**Note:** Basic SKU has no Private Endpoint (needs Premium). Access is secured with **AcrPull RBAC**, not admin user/password.

## Use in this project

Target for all app CI pipelines; AKS kubelet + ACI identity get `AcrPull`.

## Example to understand

Company warehouse for container images. Robots (AKS/ACI) have a badge (`AcrPull`) instead of a shared password (`admin_enabled = false`).
