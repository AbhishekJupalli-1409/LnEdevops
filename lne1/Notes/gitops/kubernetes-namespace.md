# Kubernetes Namespace

**File:** `gitops/.../apps/namespace.yaml`

## Introduction

A **Namespace** is a virtual cluster slice: it scopes resource names, and is where you attach RBAC, network policies, and quotas. Objects in `apps` are separate from `default`, `kube-system`, `flux-system`, `ingress-nginx`.

## Why we use it

Dumping app Deployments into `default` mixes them with experiments and makes RBAC/cleanup harder. `apps` is the dedicated drawer for user workloads.

## Real-life example

A labeled **tenant floor** in an office tower: “Apps Department.” Ingress and Flux live in other floors/wings.

## Connections

```
Namespace apps
  ├── Deployment frontend / todolist
  ├── Service frontend-service / todolist-service
  └── Ingress apps-ingress (often in apps ns)
Flux applies all of these together via apps Kustomization
```

## In this project

Created by Flux (not Terraform).
