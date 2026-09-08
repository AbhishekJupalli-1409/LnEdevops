# azurerm_private_endpoint

## Introduction

A **Private Endpoint** is a NIC with a private IP that maps to a PaaS resource over Azure Private Link. Traffic to the resource’s “data plane” stays on the Microsoft backbone / your VNet instead of public endpoints.

## Why we use it

Key Vault has `public_network_access_enabled = false`. Without a PE (or other approved private path), nothing in the VNet could reach it.

## Real-life example

Building a **private tunnel from the campus into the vault building**. You never walk through the public lobby; you enter via the tunnel door that only campus badges can use.

## Connections in this project

```
snet-pe --> Private Endpoint NIC (private IP)
              --> Private Link --> Key Vault
Private DNS zone group maps vault hostname --> PE IP
```

Postgres intentionally does **not** use this pattern; it uses Flexible Server VNet integration instead.

## How Terraform creates it

```hcl
resource "azurerm_private_endpoint" "keyvault" {
  subnet_id = var.pe_subnet_id
  private_service_connection {
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
  }
}
```

## In this project

Only Key Vault PE today; PE subnet can host more later (e.g. Premium ACR).
