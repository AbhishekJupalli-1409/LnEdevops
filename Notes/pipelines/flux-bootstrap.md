# Pipeline: Flux bootstrap

**File:** `pipelines/flux-bootstrap-azure-pipelines.yml`

## Brief introduction

Bootstraps **Flux** on AKS against this GitHub repo path `gitops/clusters/aks-centralindia`, writes `cluster-vars` ConfigMap, and reconciles apps.

## Why we create it

GitOps: desired Deployments/Services/Ingress live in git; Flux keeps the cluster matching git. Bootstrap is a one-time (or rare) cluster install of Flux controllers + sync config.

## How it works

- Pool: **`empapp-private-pool`**
- `flux bootstrap github --path=gitops/clusters/aks-centralindia ...`
- Creates `cluster-vars` with `${ACR_LOGIN_SERVER}`, `${BACKEND_PRIVATE_IP}`, `${BACKEND_PORT}` from Terraform outputs
- Flux `Kustomization` substitutes those into manifests

## Use in this project

Deploys namespace `apps`, frontend, todolist, and path-based Ingress continuously.

## Example to understand

Hiring a full-time clerk (Flux) who watches the git binder and rearranges the store (cluster) whenever the binder changes.
