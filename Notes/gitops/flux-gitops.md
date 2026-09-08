# Flux GitOps

**Tree:** `gitops/clusters/aks-centralindia/`  
**Pipeline:** `pipelines/flux-bootstrap-azure-pipelines.yml`

## Brief introduction

**Flux** continuously reconciles cluster state from git. After `flux bootstrap`, controllers and a `GitRepository`/`Kustomization` sync a path in this repo.

## Why we create it

Declarative deploys: change YAML in git → cluster updates. Avoids imperative `kubectl apply` from laptops for apps.

## How it works in this project

1. Bootstrap creates `flux-system/` (generated — not hand-authored in the download).
2. `apps-kustomization.yaml` defines a Flux `Kustomization` pointing at `./apps`.
3. `postBuild.substituteFrom` reads ConfigMap `cluster-vars` for:
   - `ACR_LOGIN_SERVER`
   - `BACKEND_PRIVATE_IP`
   - `BACKEND_PORT`
4. Reconcile interval ~5m (see CR).

## Use in this project

Keeps frontend + todolist + Ingress aligned with git.

## Example to understand

Git is the source of truth binder. Flux is the clerk who never stops checking that the store matches the binder.
