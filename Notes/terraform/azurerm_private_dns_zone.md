# azurerm_private_dns_zone

## Brief introduction

A **private DNS zone** resolves Azure Private Link / privatelink hostnames inside your VNet (e.g. `*.privatelink.vaultcore.azure.net`).

## Why we create it

Without private DNS, clients would try public endpoints. Private Postgres and Key Vault need names that resolve to private IPs.

## How Terraform creates it

```hcl
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}
```

## Use in this project

- Postgres Flexible Server VNet integration DNS
- Key Vault private endpoint DNS

## Example to understand

Internal phone book: when code asks for `myvault.vault.azure.net`, DNS answers with the private PE IP, not the public one.
