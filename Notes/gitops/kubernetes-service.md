# Kubernetes Service

**Files:**

- `apps/frontend/service.yaml`
- `apps/todolist/service.yaml`

## Brief introduction

A **Service** gives a stable virtual IP/DNS name in-cluster that load-balances to matching pods.

## Why we create it

Ingress (and other pods) should target `frontend-service` / `todolist-service`, not ephemeral pod IPs.

## How it is created

ClusterIP Services (internal only). Todolist maps Service port 80 → container 5000.

## Use in this project

Backends for Ingress path rules.

## Example to understand

Reception desk number that always forwards to whoever is currently on shift (pods).
