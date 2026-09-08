# azurerm_virtual_network

## Brief introduction

A **VNet** is your private network in Azure (like an on-prem network). Subnets, NICs, private endpoints, and many PaaS integrations attach to it.

## Why we create it

All private communication (AKS ↔ ACI ↔ Postgres ↔ agent ↔ Key Vault PE) needs one shared address space.

## How Terraform creates it

```hcl
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
```

Module: `terraform/modules/networking`.

## Use in this project

Backbone for AKS, ACI, Postgres, PE, and agent subnets.

## Example to understand

VNet `10.0.0.0/16` is the whole office building; subnets are floors for different teams (AKS, DB, agents).
