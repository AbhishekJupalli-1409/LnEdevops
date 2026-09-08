# azurerm_key_vault

## Brief introduction

**Key Vault** stores secrets, keys, and certificates with access control (here: RBAC) and optional private networking.

## Why we create it

Keep Postgres passwords, connection strings, and agent SSH keys out of git and out of plain pipeline logs where possible.

## How Terraform creates it

```hcl
resource "azurerm_key_vault" "this" {
  name                          = var.key_vault_name
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  public_network_access_enabled = false
}
```

## Use in this project

Private vault + private endpoint; secrets written after Postgres/agent exist.

## Example to understand

A locked safe in a private room (PE) — no public lobby entrance to the vault.
