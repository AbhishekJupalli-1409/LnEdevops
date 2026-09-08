# Kubernetes Namespace

**File:** `gitops/clusters/aks-centralindia/apps/namespace.yaml`

## Brief introduction

A **Namespace** partitions cluster resources (names, RBAC, quotas) — like a folder for objects.

## Why we create it

Isolate app workloads under `apps` instead of dumping into `default`.

## How it is created

Applied by Flux via the apps Kustomization (not Terraform).

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: apps
```

## Example to understand

A labeled drawer in the cluster filing cabinet where frontend/todolist objects live.
