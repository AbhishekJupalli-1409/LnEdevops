# Pipeline: Flux bootstrap

**File:** `pipelines/flux-bootstrap-azure-pipelines.yml`  
**Git path:** `gitops/clusters/aks-centralindia`

## Introduction

Bootstraps **Flux CD** on the cluster against this GitHub repo path, writes ConfigMap **`cluster-vars`** (ACR server, backend private IP/port), and reconciles the apps Kustomization so frontend, todolist, and Ingress appear.

## Why we use it

After images exist and ingress is ready, you still need a continuous, git-reviewed way to manage Kubernetes objects. Flux watches git and applies desired state — the GitOps control loop.

Bootstrap is the “install Flux + point it at the folder” step. Day-2 changes are mostly git commits, not re-running imperative kubectl.

Must use **private pool** (Flux CLI talks to private AKS API; also needs network to GitHub via NAT).

## Real-life example

Hiring a **full-time stock clerk** who always compares the shelves (cluster) to the binder in HQ (git).

Bootstrap = onboarding day (badge, radio, binder assignment).  
Afterwards the clerk self-corrects shelves every few minutes when the binder changes.

`cluster-vars` is a sticky note of values that did not exist until Terraform applied (ACR hostname, ACI IP).

## Connections

```
Pipeline (private pool)
  --> flux bootstrap github --path=gitops/clusters/aks-centralindia
        --> creates flux-system controllers + GitRepository
  --> writes ConfigMap cluster-vars:
        ACR_LOGIN_SERVER, BACKEND_PRIVATE_IP, BACKEND_PORT
  --> Flux Kustomization apps
        --> substituteFrom cluster-vars
        --> apply namespace, Deployments, Services, Ingress

GitHub gitops/ <---pull--- Flux
ACR <---pull images--- AKS (AcrPull)
Frontend env --> ACI private IP from cluster-vars
```

## In this project

Turns git manifests into running apps; see `Notes/gitops/`.
