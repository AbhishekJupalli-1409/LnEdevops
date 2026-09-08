# azurerm_kubernetes_cluster

## Introduction

**Azure Kubernetes Service (AKS)** is managed Kubernetes. Azure runs the control plane (API server, etcd, schedulers); you run application pods on node VMs in a node pool.

A **private cluster** means the API server has **no public endpoint**. Only networks that can resolve/route to the private API (here: the VNet / agent subnet) can run `kubectl`.

That is different from app traffic: a `LoadBalancer` Service can still get a **public** IP for ingress.

## Why we use it

We need a place to run two web frontends with rolling updates, Services, and Ingress — and we want GitOps (Flux). AKS is the standard Azure choice. Making the API private reduces attack surface (no random Internet `kubectl`).

## Real-life example

A **hotel**:

- **Front door for guests** = ingress public IP (`/emp`, `/to-do`).
- **Manager’s office** = Kubernetes API — locked inside the staff wing (private). Guests enjoy rooms without ever entering the manager’s office.
- Microsoft-hosted pipeline agents are like contractors **outside the building** — they cannot open the manager’s office door. You need an **on-site technician** (Agent VM) for Helm/Flux.

## Connections in this project

```
Users --HTTPS--> ingress-nginx LB (public) --> Services --> Pods (frontend, todolist)
Pods --private--> ACI backend --> Postgres

Agent VM --private--> AKS API -- helm install ingress / flux bootstrap / kubectl

AKS kubelet --AcrPull--> ACR

Flux controllers (in cluster) --pull git--> GitHub gitops path
                             --apply--> Deployments/Services/Ingress in namespace apps
```

Depends on: `snet-aks`, ACR id (for role assignment).  
Consumed by: Helm pipeline, Flux pipeline, GitOps manifests.

## How Terraform creates it

```hcl
resource "azurerm_kubernetes_cluster" "this" {
  private_cluster_enabled = true
  private_dns_zone_id     = "System"
  # node pool attached to aks subnet, kubenet + standard LB
}
```

Module: `terraform/modules/aks`.

## In this project

Cluster name like `aks-empapp-cin`. Hosts only frontend + todolist (+ ingress/Flux system). Backend stays on ACI by design.
