# Pipeline: employee backend

**File:** `pipelines/app-backend-azure-pipelines.yml`

## Brief introduction

CI for the Node/Sequelize backend: ensure Postgres driver deps, build image, push as `employee-app-backend` to ACR.

## Why we create it

ACI runs the backend from ACR. New code must become a new image for ACI to pick up (restart/deploy pipeline).

## How it works

- Pool: `ubuntu-latest`
- May add `pg` / `pg-hstore` for Postgres
- Push to ACR

## Use in this project

Image consumed by `azurerm_container_group` (private ACI), not by Flux.

## Example to understand

Same assembly line as frontend, but the “customer” is ACI inside the VNet instead of Kubernetes.
