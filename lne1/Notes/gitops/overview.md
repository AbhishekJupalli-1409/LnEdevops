# GitOps + Helm overview

## Introduction

Three layers cooperate:

| Layer | Tool | Job |
|-------|------|-----|
| Ingress controller | **Helm** (ingress-nginx chart) | Process that watches Ingress objects and opens a public LB |
| Desired app state | **Git** + **Flux** | Continuously make the cluster match YAML in `gitops/` |
| Compose YAML | **Kustomize** | List/patch plain manifests without a custom Helm chart per app |

Backend API is **not** in GitOps — it is ACI from Terraform.

## Why this split

- Helm shines for complex third-party charts (ingress-nginx).  
- Plain YAML + Flux shines for *your* apps (readable, PR-reviewed).  
- Keeping ACI out of GitOps matches “private API appliance” managed with Azure lifecycle.

## Real-life example

- **Helm** = hiring a specialist firm to install the mall’s revolving door system (standard product, many knobs).  
- **Flux + git** = the binder that says which shops exist, what they sell, and which signs hang on the door.  
- **ACI** = a separate back-office vendor contract managed by facilities (Terraform), not by the shop binder.

## Connections

```
Users --> ingress-nginx (Helm) public IP
            --> Ingress (Flux) path rules
                  --> Services (Flux)
                        --> Pods from Deployments (Flux)
                              images from ACR
                              frontend --> ACI private IP (cluster-vars)
                                            --> Postgres

Terraform provides: AKS, ACR, ACI IP, agent VM
Pipelines: Helm install + Flux bootstrap + image builds
```
