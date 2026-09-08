# random_password

## Brief introduction

Generates a strong password and stores it in Terraform state (often then copied into Key Vault).

## Why we create it

Postgres admin password should not be a hardcoded string in git.

## How Terraform creates it

```hcl
resource "random_password" "administrator" {
  length  = 24
  special = true
}
```

Fed into `azurerm_postgresql_flexible_server` and Key Vault secrets.

## Use in this project

Administrator password for the Flexible Server; also stored as a Key Vault secret.

## Example to understand

Terraform rolls a dice-password once, remembers it in state, and puts a copy in the vault for humans/apps.
