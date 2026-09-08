# azurerm_postgresql_flexible_server

## Brief introduction

Managed PostgreSQL (**Flexible Server**) with compute, storage, and optional private networking.

## Why we create it

Employee backend needs a relational DB. Requirement: private communication — implemented as **VNet integration** (delegated subnet), not public server + PE.

## How Terraform creates it

```hcl
resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.server_name
  delegated_subnet_id           = var.postgres_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false
  administrator_password        = random_password.administrator.result
  # ...
}
```

## Use in this project

Private DB for the Node/Sequelize employee backend on ACI.

## Example to understand

Database lives on the “Postgres floor” of the VNet. There is no public street address — only internal doors.
