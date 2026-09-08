# azurerm_role_assignment

## Introduction

Azure **RBAC role assignment** grants a security principal (user, SP, managed identity) a role on a scope (subscription, RG, resource).

Examples: `AcrPull`, `Key Vault Secrets Officer`.

## Why we use it

Passwordless automation. Instead of putting ACR admin passwords in ACI/AKS, identities get `AcrPull`. Instead of portal-only secret entry, the Terraform identity can write Key Vault secrets.

## Real-life example

Issuing **employee badges with door permissions**:

- Badge “Warehouse Puller” opens the image warehouse (ACR).  
- Badge “Vault Clerk” can deposit envelopes (Key Vault secrets).  
Badges beat sharing one master key in Slack.

## Connections in this project

```
AKS kubelet identity --AcrPull--> ACR
ACI user-assigned identity --AcrPull--> ACR
Terraform apply identity --Secrets Officer--> Key Vault
  --> can create postgres password / connection string / SSH key secrets
```

Without AcrPull, pods/ACI fail with image pull errors even if the image exists.

## How Terraform creates it

Multiple `azurerm_role_assignment` resources across `aks`, `aci`, and `keyvault` modules.

## In this project

Security glue between identities and data/image planes.
