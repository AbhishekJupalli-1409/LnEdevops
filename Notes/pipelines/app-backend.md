# Pipeline: employee backend

**File:** `pipelines/app-backend-azure-pipelines.yml`

## Introduction

CI for the Node/Sequelize **employee backend**. Builds/pushes `employee-app-backend` to ACR. May patch in Postgres drivers (`pg`, `pg-hstore`) so the image can talk to Flexible Server.

## Why we use it

ACI runs whatever image you give it. Without CI, the private API never receives new code. Separating backend CI from frontend CI lets API and UI version independently.

## Real-life example

Manufacturing **back-office equipment** (API appliances) stored in the same warehouse (ACR) as storefront displays, but delivered to the staff corridor (ACI), not the shop floor (AKS).

## Connections

```
Backend source
  --> pipeline --> ACR (employee-app-backend)
        --> ACI container group pulls via UAMI AcrPull
              --> ACI uses Postgres connection (private)
              --> Frontend pods call ACI private IP

Not managed by Flux. Refresh/restart often via aci-backend-deploy pipeline
or terraform apply when env (CORS/WHITELIST_URLS) changes.
```

## In this project

Image producer for `azurerm_container_group.backend`.
