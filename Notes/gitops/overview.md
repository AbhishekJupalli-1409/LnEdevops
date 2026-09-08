# GitOps + Helm overview

## Brief introduction

- **Helm** — package manager used here only for **ingress-nginx** (controller).
- **Flux** — GitOps operator that syncs `gitops/clusters/aks-centralindia` into AKS.
- **Kustomize** — lists and composes raw Kubernetes YAML for apps (no custom Helm charts for apps).

## Why this design

| Concern | Tool |
|---------|------|
| Public HTTP entry | Helm ingress-nginx |
| App desired state | Git + Flux |
| Image/registry & backend IP placeholders | Flux `postBuild` substituteFrom `cluster-vars` |
| Backend API | ACI (not in GitOps) |

## How traffic flows

```
Internet → ingress-nginx LB IP
            ├─ /emp     → frontend-service → frontend pods
            ├─ /to-do   → todolist-service → todolist pods
            └─ /static  → todolist static assets
Frontend pods → BACKEND_PRIVATE_IP:PORT (ACI) → Postgres (VNet)
```

## Paths in repo

- `helm/nginx-ingress-values.yaml`
- `gitops/clusters/aks-centralindia/apps-kustomization.yaml`
- `gitops/clusters/aks-centralindia/apps/**`
