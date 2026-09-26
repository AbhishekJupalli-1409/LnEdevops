# azurerm_container_registry

## Introduction

**Azure Container Registry (ACR)** stores Docker/OCI images. Kubernetes and ACI pull images from registries to run containers.

## Why we use it

App pipelines produce images for frontend, backend, and todolist. AKS and ACI must pull from a controlled registry. Using Azure AD **AcrPull** (not admin username/password) is safer and fits managed identities.

**SKU note:** Basic has no Private Endpoint (Premium required). This project secures pulls with RBAC instead of network isolation on ACR.

## Real-life example

A **secured warehouse of sealed product boxes** (images).

Factory lines (pipelines) deliver new boxes. Store robots (AKS/ACI) present an employee badge (`AcrPull`) to pick boxes. There is no shared master key hanging on a nail (`admin_enabled = false`).

## Connections in this project

```
App pipelines --docker push--> ACR

AKS kubelet identity --role AcrPull--> ACR --pull--> frontend/todolist pods
ACI user-assigned identity --role AcrPull--> ACR --pull--> backend container

Flux manifests reference ${ACR_LOGIN_SERVER}/image:tag
  (substituted from cluster-vars ConfigMap)
```

## How Terraform creates it

```hcl
resource "azurerm_container_registry" "this" {
  sku           = "Basic"
  admin_enabled = false
}
```

Module: `terraform/modules/acr`.

## In this project

Central image hub between CI and runtimes.
