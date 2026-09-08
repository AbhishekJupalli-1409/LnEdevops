# azurerm_storage_container

## Brief introduction

A **blob container** is a folder-like namespace inside a storage account. Blobs (files) live inside containers.

## Why we create it

Terraform’s `azurerm` backend needs a dedicated private container for the state file.

## How Terraform creates it

```hcl
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}
```

## Use in this project

Holds the remote state blob for the centralindia environment.

## Example to understand

Storage account = hard drive; container `tfstate` = folder named “terraform-state”; the `.tfstate` file is the document inside.
