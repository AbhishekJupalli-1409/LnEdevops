# azuredevops_serviceendpoint_azurerm

## Brief introduction

Service connection from AzDO to an Azure subscription (ARM) so pipelines can run AzureCLI/Terraform against your cloud.

## Why we create it

Infra and ACI deploy pipelines need authenticated Azure access.

## How Terraform creates it

```hcl
resource "azuredevops_serviceendpoint_azurerm" "subscription" {
  project_id                             = azuredevops_project.this.id
  service_endpoint_name                  = "empapp-arm"
  azurerm_spn_tenantid                   = var.tenant_id
  azurerm_subscription_id                = var.subscription_id
  azurerm_subscription_name              = var.subscription_name
}
```

## Use in this project

Used by Terraform plan/apply and other Azure tasks (`empapp-arm` by default).

## Example to understand

A saved “login to Azure” credential inside the pipeline project.
