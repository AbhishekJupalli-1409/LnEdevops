# azurerm_private_endpoint

## Brief introduction

A **Private Endpoint** is a NIC with a private IP that maps to a PaaS resource over Private Link.

## Why we create it

Key Vault has public access disabled; the PE is how VNet clients reach it privately.

## How Terraform creates it

```hcl
resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-keyvault"
  subnet_id           = var.pe_subnet_id
  private_service_connection {
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
  private_dns_zone_group { ... }
}
```

## Use in this project

Private access path to Key Vault from the platform VNet.

## Example to understand

A private tunnel from your VNet floor (`snet-pe`) straight into the Key Vault service.
