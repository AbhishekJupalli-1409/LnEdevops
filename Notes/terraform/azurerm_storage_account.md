# azurerm_storage_account

## Introduction

An Azure **Storage Account** is the parent service for Blob, File, Queue, and Table storage. For Terraform, we mainly care about **Blob** storage: a durable place to keep the remote `terraform.tfstate` file.

## Why we use it

Terraform state records every resource ID and attribute. If state lives only on one laptop:

- Teammates overwrite each other.
- Pipelines cannot safely plan/apply.
- A lost laptop means “we don’t know what exists in Azure.”

Remote state in a storage account is the team’s shared source of truth. Blob **versioning** helps recover from accidental corruption.

## Real-life example

A construction company’s **central blueprint vault**.

Every contractor (developer, pipeline) must check the same latest blueprint (state) before changing the building. If blueprints lived in someone’s backpack, two crews would build conflicting walls.

## Connections in this project

```
Bootstrap (local state, run once)
  --> creates Storage Account + container "tfstate"
        --> referenced by terraform/envs/centralindia/backend.tf
              --> infra pipeline terraform init/plan/apply
```

This storage account is **not** for app images (that is ACR) or secrets (that is Key Vault).

## How Terraform creates it

Only in `terraform/bootstrap/main.tf` (intentionally **local** state, because it creates the remote backend itself):

```hcl
resource "azurerm_storage_account" "state" {
  name                     = "tfstateemp${random_string.sa_suffix.result}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  allow_nested_items_to_be_public = false
  blob_properties { versioning_enabled = true }
}
```

## In this project

Prerequisite for all later Terraform. See `scripts/bootstrap-backend.sh` / runbook step 0.
