# random_password

## Introduction

Generates a cryptographic-quality password and stores it in Terraform state. Often passed into databases and copied into Key Vault for humans/apps.

## Why we use it

Hardcoding `Password123!` in git is a real-world breach pattern. Generation + Key Vault storage keeps secrets out of the repo.

## Real-life example

A password manager’s **Generate** button: create once, save in the vault, never commit to the team wiki.

## Connections in this project

```
random_password.administrator
  --> azurerm_postgresql_flexible_server.administrator_password
  --> azurerm_key_vault_secret.postgres_admin_password
  --> also used when composing connection string secret
  --> ACI backend uses DB credentials (via env/config from TF)
```

## How Terraform creates it

```hcl
resource "random_password" "administrator" {
  length  = 24
  special = true
}
```

Module: `terraform/modules/postgresql`.

## In this project

Root credential for the Flexible Server admin user.
