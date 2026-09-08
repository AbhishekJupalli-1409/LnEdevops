# azurerm_key_vault_secret

## Brief introduction

Stores a named secret value inside Key Vault.

## Why we create it

Persist generated credentials for later use (apps, operators, docs generation) without committing them to git.

## How Terraform creates it

```hcl
resource "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  value        = var.postgres_admin_password
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_key_vault_secret" "extra" {
  for_each = var.extra_secrets
  name     = each.key
  value    = each.value
  # e.g. agent SSH private key
}
```

## Use in this project

Postgres admin password, connection string, and extra secrets (agent key).

## Example to understand

Labeled envelopes in the safe: `postgres-admin-password`, `postgres-connection-string`, …
