# random_string

## Brief introduction

The `random` provider generates strings (or other values) that Terraform stores in state. Used so globally unique Azure names do not collide.

## Why we create it

ACR, Key Vault, storage accounts, and Postgres server names must be **globally unique**. A short random suffix avoids rename conflicts when many people deploy the same template.

## How Terraform creates it

```hcl
resource "random_string" "suffix" {
  length  = 5
  lower   = true
  upper   = false
  numeric = true
  special = false
}
```

Used in names like `acrempapp${random_string.suffix.result}` and `kv-empapp-${random_string.suffix.result}`.

## Use in this project

- Bootstrap: `sa_suffix` (6 chars) for the state storage account name.
- Env root: `suffix` (5 chars) shared across ACR, Key Vault, Postgres.

## Example to understand

Without a suffix, two students both naming ACR `acrempapp` would fail. With `acrempapp7k2qm`, each deployment gets its own unique registry.
