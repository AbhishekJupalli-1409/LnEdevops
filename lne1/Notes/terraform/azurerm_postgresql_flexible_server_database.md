# azurerm_postgresql_flexible_server_database

## Introduction

Creates a **logical database** on an existing Flexible Server (similar to `CREATE DATABASE`).

## Why we use it

Apps typically use a dedicated database name (not the default `postgres` maintenance DB). Schema migrations and connection strings point at that name.

## Real-life example

One archive building (server) contains many labeled filing cabinets (databases). The employee app only opens the cabinet named **employee**.

## Connections in this project

```
Flexible Server
  └── database "employee"
        <-- connection string secret in Key Vault
        <-- ACI backend Sequelize config
```

## How Terraform creates it

```hcl
resource "azurerm_postgresql_flexible_server_database" "employee" {
  name      = "employee"
  server_id = azurerm_postgresql_flexible_server.this.id
}
```

## In this project

Target DB for employee backend tables.
