# azurerm_storage_container

## Introduction

A **blob container** is a namespace (folder-like) inside a storage account. Blobs (files) live inside containers. Access can be private or public; Terraform state must be **private**.

## Why we use it

The AzureRM Terraform backend expects: storage account + container + state file key. The container separates tfstate blobs from any other blobs you might store later.

## Real-life example

Inside the blueprint vault building (storage account), the room labeled **“TFSTATE only”** (container). Other rooms might later hold logs or backups; you do not mix them so permissions stay clear.

## Connections in this project

```
Storage Account
  └── container "tfstate" (private)
        └── blob key e.g. centralindia.terraform.tfstate
              └── locked/read by terraform plan/apply (local + Azure Pipelines)
```

## How Terraform creates it

```hcl
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}
```

## In this project

Created once by bootstrap; never used for application data.
