# azurerm_postgresql_flexible_server_database

## Brief introduction

Creates a logical **database** on a Flexible Server (like `CREATE DATABASE`).

## Why we create it

App expects a dedicated database (not only the default `postgres` DB).

## How Terraform creates it

```hcl
resource "azurerm_postgresql_flexible_server_database" "employee" {
  name      = "employee"
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
```

## Use in this project

`employee` database for the employee app schema/tables.

## Example to understand

Server = apartment building; database `employee` = one apartment the app lives in.
