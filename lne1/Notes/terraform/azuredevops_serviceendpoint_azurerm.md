# azuredevops_serviceendpoint_azurerm

## Introduction

A **service connection** to Azure Resource Manager so pipeline tasks (`AzureCLI@2`, Terraform against Azure, etc.) can authenticate to a subscription.

## Why we use it

Infra plan/apply and ACI restart need Azure permissions without pasting SP secrets into every YAML file.

## Real-life example

A **corporate credit card on file** for the construction crew: pipelines can purchase/modify Azure resources within allowed limits (RBAC on the SP).

## Connections in this project

```
Pipeline (infra-terraform, aci-backend-deploy, ...)
  --> uses ARM service connection (e.g. empapp-arm)
        --> Azure APIs create/update RG, AKS, ACI, ...
```

## How Terraform creates it

`azuredevops_serviceendpoint_azurerm.subscription` in azuredevops module.

## In this project

Default name often `empapp-arm` (parameterized in YAML).
