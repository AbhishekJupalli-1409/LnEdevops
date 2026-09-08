# Kubernetes Ingress

**File:** `apps/ingress/ingress.yaml`

## Brief introduction

An **Ingress** object describes HTTP routing rules (host/path → Service). An Ingress **controller** (ingress-nginx) implements them.

## Why we create it

One public IP, multiple apps: `/emp` and `/to-do` (plus `/static` for todolist assets).

## How it is created

Flux applies the Ingress; ingress-nginx (Helm) watches it and programs NGINX.

```yaml
# conceptual
paths:
  - /emp    → frontend-service:80
  - /to-do  → todolist-service:80
  - /static → todolist-service:80
```

## Use in this project

Public path-based routing to AKS apps (backend stays private on ACI).

## Example to understand

Directory signs at the mall entrance: “Electronics → /emp”, “Errands → /to-do”.
