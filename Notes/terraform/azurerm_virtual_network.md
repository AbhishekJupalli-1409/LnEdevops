# azurerm_virtual_network

## Introduction

An Azure **Virtual Network (VNet)** is your private IP address space in Azure — equivalent to a corporate LAN in the cloud. Subnets, NICs, private endpoints, and many PaaS private integrations attach to it. Resources in the same VNet (with NSG allow) can talk privately without traversing the public internet.

## Why we use it

The whole security story of this project depends on private paths:

- Frontend → backend  
- Backend → Postgres  
- Agent → AKS API  
- Clients → Key Vault via Private Endpoint  

Without a VNet, those become public endpoints or impossible.

## Real-life example

A **company campus network**.

Buildings (subnets) share the campus backbone (VNet). Employees walk internal corridors (private IPs). The public street is outside the fence. Guests only enter through the lobby (ingress), not into the records room (database).

## Connections in this project

```
VNet
 ├── snet-aks        --> AKS nodes, ingress controller, app pods
 ├── snet-aci        --> ACI backend (+ NSG allow from AKS only)
 ├── snet-postgres   --> Flexible Server (delegated)
 ├── snet-pe         --> Key Vault Private Endpoint
 └── snet-agent      --> Agent VM (+ NAT Gateway association)

Private DNS zones --link--> this VNet
```

## How Terraform creates it

`terraform/modules/networking/main.tf`:

```hcl
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
}
```

## In this project

Single platform VNet in Central India; all private communication stays inside it.
