# azurerm_private_dns_zone_virtual_network_link

## Introduction

Links a private DNS zone to a VNet so resolvers in that VNet use the zone. A zone with no link is unused by that network.

## Why we use it

Create zone → link to platform VNet → AKS/ACI/VM lookups succeed for privatelink names.

## Real-life example

Connecting the internal phone directory to **this campus’s phone system**. Another campus needs its own link to use the same directory style.

## Connections in this project

```
postgres private DNS zone --link--> platform VNet
keyvault private DNS zone --link--> platform VNet
```

Enables ACI→Postgres and VNet→Key Vault PE by hostname.

## How Terraform creates it

One link resource per zone in the networking module.

## In this project

Required companion to both private DNS zones.
