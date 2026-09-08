# azurerm_subscription_policy_assignment

## Introduction

**Azure Policy** lets an organization define rules (“definitions”) and **assign** them to a scope (management group, subscription, RG). Assignments can Audit or **Deny** non-compliant resources.

This resource assigns built-in definitions to the **subscription**.

## Why we use it

Cloud accounts drift: someone creates a VM in East US “just for a quick test,” forgets cost tags, or attaches a public IP to a NIC and accidentally exposes SSH.

Policy is preventative governance — like building codes — so Terraform and portal clicks alike are forced into safe defaults for this learning platform.

## Real-life example

City **zoning and building codes**:

- You may only build in certain districts (allowed locations = India regions).
- Every property must list owner/tax IDs (required tags).
- Apartment doors may not face the highway with unlocked public entrances (deny public IP on NICs).

Inspectors (Azure Policy) reject illegal construction at permit time (resource create/update).

## Connections in this project

```
Policy assignments (subscription)
  --> constrain everything Terraform creates:
        location must be allowed
        tags must exist
        Agent VM NIC cannot have public IP
          --> therefore Agent uses NAT Gateway for outbound instead
```

Module: `terraform/modules/policy`.

## How Terraform creates it

Four assignments using known built-in definition GUIDs (see `docs/ARCHITECTURE_NOTES.md`):

1. Allowed locations  
2. Require tag `Business Unit`  
3. Require tag `Cost Center`  
4. Network interfaces should not have public IPs  

## In this project

Applied early in the env root so later modules inherit the guardrails.
