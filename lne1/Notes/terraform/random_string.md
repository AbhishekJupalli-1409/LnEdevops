# random_string

## Introduction

The Terraform **random** provider can generate strings, passwords, UUIDs, etc., and store them in state so they stay stable across applies (unless you force recreation).

`random_string` is used when Azure requires a **globally unique** name (registry, storage account, Key Vault, Postgres server hostname).

## Why we use it

If every student or environment hardcoded `acrempapp`, the second deployment in the world would fail with “name already taken.” A short random suffix (`acrempapp7k2qm`) makes collisions unlikely while keeping names readable.

## Real-life example

Like assigning **hotel room key codes** or **license plate suffixes**.

Two hotels both named “Grand Plaza” need unique reservation codes (`GP-A92F1` vs `GP-B31K4`) so booking systems do not collide. The suffix is not secret identity — it is uniqueness.

## Connections in this project

```
random_string.suffix (env)
   --> ACR name: acrempapp${suffix}
   --> Key Vault name: kv-empapp-${suffix}
   --> Postgres server name: psql-empapp-${suffix}

random_string.sa_suffix (bootstrap)
   --> Storage account: tfstateemp${sa_suffix}
```

Those named resources are then referenced by AKS/ACI (ACR), apps (Postgres hostname via connection string), and pipelines (ACR login server).

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

## In this project

Shared env suffix keeps related resource names visually grouped (`…7k2qm` everywhere) while remaining unique.
