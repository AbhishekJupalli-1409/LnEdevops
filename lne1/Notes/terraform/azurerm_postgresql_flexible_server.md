# azurerm_postgresql_flexible_server

## Introduction

**Azure Database for PostgreSQL – Flexible Server** is managed PostgreSQL (patching, backups, compute tiers). Networking modes include public access and **private access via VNet integration** (delegated subnet).

## Why we use it

The employee backend is a classic 3-tier app: UI → API → relational DB. Sequelize expects Postgres. Private VNet integration matches the requirement that backend↔DB traffic never goes public.

## Real-life example

A bank **records room inside the staff wing**.

There is no street address for the records room. Only people already inside the campus (ACI on the private subnet path) can walk there. Putting a “private receptionist” in front of a street-facing vault (public DB + PE) is weaker than placing the vault fully inside.

## Connections in this project

```
ACI backend --private SQL--> Flexible Server (snet-postgres)
Flexible Server uses:
  delegated subnet snet-postgres
  private DNS zone link
  random admin password --> also stored in Key Vault

Frontend does NOT talk to Postgres directly (only via API).
```

## How Terraform creates it

```hcl
resource "azurerm_postgresql_flexible_server" "this" {
  delegated_subnet_id           = var.postgres_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false
}
```

## In this project

Database engine for employee data; companion database resource creates `employee` DB.
