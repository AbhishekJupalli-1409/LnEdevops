# Pipelines overview

## Introduction

**Azure Pipelines** are automated workflows defined in YAML. In this repo they cover four jobs:

1. **Build cloud** — Terraform plan/apply  
2. **Build software** — Docker images for three apps into ACR  
3. **Open the front door** — Helm install ingress-nginx on private AKS  
4. **Wire GitOps + refresh API** — Flux bootstrap and ACI restart  

Some jobs run on Microsoft-hosted `ubuntu-latest` (talk to Azure ARM / Docker registries over the public Azure control plane). Jobs that need `kubectl`/`helm`/`flux` against a **private AKS API** must run on **`empapp-private-pool`** (the Agent VM inside the VNet).

## Why we use pipelines

Manual deploys do not scale and are hard to audit. Pipelines give:

- Repeatability (same steps every time)  
- Approvals (Terraform apply gate)  
- Separation of duties (who can push images vs who can apply infra)  
- A clear order matching the runbook  

## Real-life example

A factory with **multiple specialized assembly lines**:

- Line A builds the building (Terraform) using city permits (ARM).  
- Lines B/C/D manufacture products (container images) and store them in the warehouse (ACR).  
- Line E (on-site only) installs the mall front door (ingress).  
- Line F (on-site only) hires the stock clerk who reads the binder (Flux).  
- Line G restarts the back-office window after the street address is known (ACI CORS).  

External contractors can work lines A–D and G. Lines E–F require the resident engineer on campus.

## Connections (full chain)

```
Variable group empapp-shared-vars + service connections (ARM/ACR/GitHub)
        │
        ▼
infra-terraform ──ARM──► Azure resources (VNet, AKS, ACR, Postgres, ACI, Agent VM, KV)
        │
        ▼
app-*-pipelines ──push──► ACR images
        │
        ▼
ingress-nginx-helm (private pool) ──helm──► public LB IP on AKS
        │
        ▼
flux-bootstrap (private pool) ──flux──► Deployments/Services/Ingress from git
        │
        ▼
aci-backend-deploy ──ARM──► refresh backend with ingress origin / new image
```

Shared inputs: `empapp-shared-vars`, ARM connection (`empapp-arm`), ACR connection, GitHub token where needed.
