# azurerm_storage_account

## Brief introduction

Azure Storage Account is the parent for Blob, File, Queue, and Table storage. Blob containers inside it hold files (including Terraform state).

## Why we create it

Terraform needs a **remote state** backend so team members and pipelines share one source of truth (not laptop-local `terraform.tfstate`).

## How Terraform creates it

Only in **bootstrap** (local state), before the env uses it as a backend:

```hcl
resource "azurerm_storage_account" "state" {
  name                            = "tfstateemp${random_string.sa_suffix.result}"
  resource_group_name             = azurerm_resource_group.state.name
  location                        = azurerm_resource_group.state.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
  }
}
```

## Use in this project

Stores the `tfstate` blob container used by `terraform/envs/centralindia/backend.tf`.

## Example to understand

Like a shared Google Drive folder for “current infrastructure truth.” Versioning keeps history if a bad apply corrupts state.
