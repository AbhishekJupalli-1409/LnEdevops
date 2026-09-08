# azurerm_container_group

## Introduction

**Azure Container Instances (ACI)** runs containers without you managing VMs or a full orchestrator. A **container group** is the scheduling unit (one or more containers sharing a network lifecycle). With subnet injection, ACI gets a **private IP** in your VNet.

## Why we use it

The employee **backend API** should be private and simple. Putting it on ACI (instead of AKS) shows a split architecture: web UIs on Kubernetes/GitOps, API on ACI still inside the same VNet talking to Postgres. NSG ensures only AKS can call it.

## Real-life example

A **back-office service window** inside the staff corridor.

Customers never see it. Shop clerks (frontend pods) walk the private corridor and knock on the window (private IP:port). The window staff look up records in the archive (Postgres).

## Connections in this project

```
ACR image employee-app-backend
  --pulled by UAMI--> ACI group in snet-aci (private IP)

Frontend pods --HTTP--> BACKEND_PRIVATE_IP:PORT
  (allowed by ACI NSG from AKS subnet)

ACI --SQL--> PostgreSQL Flexible Server

Flux cluster-vars includes BACKEND_PRIVATE_IP / BACKEND_PORT
  so frontend Deployment env can point at ACI

CORS / WHITELIST_URLS may need ingress public IP
  --> updated via terraform.tfvars or aci-backend-deploy pipeline
```

## How Terraform creates it

`azurerm_container_group.backend` in `terraform/modules/aci` with `ip_address_type = Private` and subnet ids.

## In this project

Private API tier for the employee app (not for todolist).
