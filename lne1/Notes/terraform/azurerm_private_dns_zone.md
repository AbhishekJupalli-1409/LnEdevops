# azurerm_private_dns_zone

## Introduction

**Private DNS zones** resolve special Azure hostnames (often `*.privatelink...`) to **private IPs** inside your VNet. Without them, clients may resolve the public endpoint or fail to resolve Private Link names.

## Why we use it

Key Vault is private (PE). Postgres Flexible Server uses private DNS for VNet integration. Apps and Terraform need names like `*.postgres.database.azure.com` / vault hostnames to resolve correctly inside the VNet.

## Real-life example

A company’s **internal phone directory**.

When you dial “Key Vault,” the directory returns the **internal extension** (private IP), not the public customer hotline. External people don’t get that directory.

## Connections in this project

```
Private DNS zone postgres  --link--> VNet  --> Flexible Server private hostname works for ACI
Private DNS zone keyvault  --link--> VNet  --> PE NIC IP answers vault hostname for VNet clients
```

## How Terraform creates it

Zones:

- `privatelink.postgres.database.azure.com`
- `privatelink.vaultcore.azure.net`

## In this project

Invisible glue that makes private PaaS “just work” by name.
