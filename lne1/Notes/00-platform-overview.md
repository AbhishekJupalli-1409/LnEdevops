# Platform overview (detailed)

## What this platform is

LearnAndEarn is a small but production-shaped Azure platform for two user-facing apps and one private API:

| Piece | What it is | Where it runs |
|-------|------------|---------------|
| Employee frontend | React UI | Private **AKS** (managed by Flux GitOps) |
| Todo List | Flask UI | Same private **AKS** |
| Employee backend | Node/Sequelize API | Private **Azure Container Instances (ACI)** |
| Database | PostgreSQL | **Flexible Server** with VNet integration (no public path) |

Users only ever see **one public IP** (ingress-nginx LoadBalancer). Paths decide which app they hit:

- `http://<INGRESS-IP>/emp` → Employee frontend
- `http://<INGRESS-IP>/to-do` → Todo List

The backend and database are **never** on the public internet. Frontend pods call the backend’s **private IP** inside the VNet; the backend talks to Postgres on the private Postgres subnet.

## Why this design (real-world thinking)

In real companies you usually want:

1. **Public only what customers need** (the website).
2. **Private everything else** (API, DB, secrets, admin APIs).
3. **Repeatable builds** (Terraform + pipelines), not “someone clicked in the portal.”
4. **Git as the source of truth for apps** (GitOps), so deploys are reviewable like code.

This repo practices that pattern at a learnable size.

### Real-life analogy: a mall

Imagine a shopping mall:

- **Public entrance** = ingress-nginx public LoadBalancer IP (street door).
- **Storefronts** = `/emp` and `/to-do` (shops customers walk into).
- **Back office / warehouse API** = ACI backend (staff-only corridor; customers don’t enter).
- **Vault room** = Key Vault + Private Endpoint (keys and passwords).
- **Records room** = PostgreSQL (only back office can reach it).
- **Security desk (admin)** = AKS API server — **private**, so random people on the street cannot run `kubectl`.
- **Night-shift technician who lives on site** = self-hosted Agent VM (can reach the private security desk to install gates/Helm and set up Flux).
- **City building codes** = Azure Policy (allowed city = India regions, must have cost tags, no public NIC on apartments).
- **City warehouse for packages** = ACR (container images).
- **City planning office + construction crews** = Azure DevOps pipelines + Terraform.

## End-to-end connection story

Follow one user request and one deploy:

### A) User opens the Employee app

```
Browser
  --HTTPS--> ingress-nginx (public LB IP on AKS)
               --/emp--> frontend Service --> frontend Pods
                            --private HTTP--> ACI Backend (private IP)
                                                 --SQL--> PostgreSQL (private)
```

Meanwhile Todo List is the same front door, different path (`/to-do`), and does **not** need the ACI backend.

### B) How software gets there

```
Developer pushes code
  --> App pipelines (Microsoft-hosted) build Docker images
  --> docker push --> ACR
  --> Flux (on AKS) sees git desired state / new image tags
  --> pulls images from ACR using AcrPull RBAC
  --> runs frontend + todolist pods

Backend image similarly lands in ACR;
ACI (with its own managed identity + AcrPull) runs that image privately.
```

### C) How the cluster itself was born

```
Bootstrap Terraform (once) --> Storage Account for tfstate
Env Terraform --> RG, Policy, VNet/subnets/NSG/NAT/DNS,
                 ACR, private AKS, Postgres, Key Vault+PE,
                 ACI backend, Agent VM, (optional AzDO wiring)
Ingress Helm pipeline (on Agent VM) --> public LB IP
Flux bootstrap pipeline (on Agent VM) --> GitOps apps
Optional ACI restart --> CORS allow-list includes real ingress IP
```

## How notes are organized

Each resource note now includes:

1. **Introduction** — what the Azure/K8s object is  
2. **Why we use it** — problem it solves here  
3. **Real-life example** — analogy outside cloud  
4. **Connections** — what talks to what in *this* repo  
5. **How Terraform / pipeline creates it** — code shape  
6. **In this project** — concrete names/paths  

See also: [architecture-diagram.png](architecture-diagram.png) / [architecture-diagram.svg](architecture-diagram.svg).
