# azurerm_private_dns_zone_virtual_network_link

## Brief introduction

Links a private DNS zone to a VNet so VMs/pods in that VNet can resolve the zone.

## Why we create it

A private DNS zone is unused until linked to the network that needs it.

## How Terraform creates it

```hcl
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "link-postgres"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.this.id
}
```

## Use in this project

Links Postgres and Key Vault privatelink zones to the platform VNet.

## Example to understand

Connecting the internal phone book to this office building’s network.
