# azurerm_key_vault

## Introduction

**Azure Key Vault** stores secrets, keys, and certificates. This project enables **RBAC** authorization and disables public network access so entry is via Private Endpoint.

## Why we use it

Passwords and SSH private keys must not live in git or casually in chat logs. Key Vault is the managed secret store operators (and sometimes apps) read from.

## Real-life example

A **bank vault room** with badge access (RBAC) and **no street entrance** (public access off). You reach it through a private tunnel from campus (Private Endpoint).

## Connections in this project

```
Key Vault (public access off)
  <-- Private Endpoint in snet-pe
  <-- Private DNS vaultcore zone

Secrets written by Terraform (with Secrets Officer role):
  - postgres admin password
  - postgres connection string
  - extra (e.g. agent SSH private key)

Consumers: humans/scripts (credentials doc), potentially apps later
```

## How Terraform creates it

Module `terraform/modules/keyvault` with RBAC + PE + secrets.

## In this project

Secret plane companion to the data plane (Postgres) and ops plane (agent SSH).
