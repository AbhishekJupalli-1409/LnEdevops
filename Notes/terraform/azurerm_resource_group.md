# azurerm_resource_group

## Brief introduction

A **resource group** is a logical container in Azure. Almost every other Azure resource must live in one. Deleting a RG can delete all resources inside it.

## Why we create it

- Groups platform resources (or state resources) under one name, location, and tags.
- Satisfies Azure policy tags (`Business Unit`, `Cost Center`) at the container level and for child resources.

## How Terraform creates it

**Bootstrap** (`terraform/bootstrap/main.tf`) — RG for Terraform state storage.  
**Environment** (`terraform/envs/centralindia/main.tf`) — main platform RG.

```hcl
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}
```

## Use in this project

| Instance | Purpose |
|----------|---------|
| `state` | Holds the storage account for remote Terraform state |
| `this` | Holds VNet, AKS, ACR, Postgres, Key Vault, ACI, agent VM |

## Example to understand

Think of a RG like a project folder: `empapp-rg` holds everything for the employee platform so you can find, tag, and (if needed) tear down the whole stack together.
