# Platform overview

## What this repo builds

An Azure platform in **Central India** for:

| Workload | Runtime | Access |
|----------|---------|--------|
| Employee frontend (React) | Private AKS via Flux | Public path `/emp` on ingress LB |
| Todo List (Flask) | Private AKS via Flux | Public path `/to-do` on ingress LB |
| Employee backend (Node) | Private Azure Container Instances | Private IP only (VNet) |
| Database | PostgreSQL Flexible Server | VNet-integrated (no public path) |

## Why this shape

- **Private AKS API** — cluster control plane is not on the public internet.
- **Public app ingress** — ingress-nginx `LoadBalancer` still gets a public IP (API private ≠ apps unreachable).
- **Private backend + DB** — frontend→backend and backend→Postgres stay inside the VNet.
- **Self-hosted agent VM** — Microsoft-hosted agents cannot reach a private AKS API; a VM in the VNet runs Helm/Flux/kubectl jobs.
- **Flux GitOps** — desired K8s state lives in git; Flux reconciles the cluster.

## How pieces connect

```
Bootstrap TF → state storage
     ↓
Env TF → RG, policy, VNet, ACR, AKS, Postgres, Key Vault, ACI, agent VM, (optional AzDO)
     ↓
App pipelines → images into ACR
     ↓
Ingress Helm pipeline (private pool) → public LB IP
     ↓
Flux bootstrap pipeline (private pool) → frontend + todolist
     ↓
ACI restart (optional) → CORS with real ingress IP
```

## Code map

- `terraform/bootstrap/` — one-shot remote state
- `terraform/envs/centralindia/` — root that wires modules
- `terraform/modules/*` — reusable Azure pieces
- `pipelines/` — Azure DevOps YAML
- `gitops/clusters/aks-centralindia/` — Flux + app manifests
- `helm/nginx-ingress-values.yaml` — ingress-nginx values
