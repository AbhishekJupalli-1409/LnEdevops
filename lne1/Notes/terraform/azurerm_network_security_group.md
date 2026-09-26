# azurerm_network_security_group

## Introduction

A **Network Security Group (NSG)** is a stateful packet filter attached to subnets or NICs. Rules allow or deny traffic by port, protocol, and source/destination.

## Why we use it

Private IP alone is not enough: without NSGs, any subnet in the VNet might reach the backend. We want **AKS → ACI on the app port only**, and deny other inbound to ACI.

AKS subnet also gets an NSG aligned with Azure LB / platform expectations.

## Real-life example

**Floor access control lists**:

- Shop floor staff may knock on the back-office door (backend port).
- Random visitors from other floors cannot.
- A default “deny other inbound” sign is posted on the back office.

## Connections in this project

```
NSG aks  --> associated with snet-aks
NSG aci  --> associated with snet-aci
             rules:
               AllowFromAks (priority 100)
               Deny other inbound (priority 200)

Frontend pods (in AKS) --allowed--> ACI backend port
Random Internet        --blocked--> ACI (also no public IP)
Other subnets          --blocked by deny rule--> ACI (unless allowed)
```

## How Terraform creates it

`azurerm_network_security_group` resources plus rule and association resources in the networking module.

## In this project

Critical for “backend is private and least-privilege reachable.”
