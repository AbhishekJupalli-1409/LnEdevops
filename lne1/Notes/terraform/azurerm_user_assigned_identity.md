# azurerm_user_assigned_identity

## Introduction

A **user-assigned managed identity (UAMI)** is a standalone Azure AD identity you attach to one or more Azure resources. Unlike system-assigned, it can outlive a single resource and be reused.

## Why we use it

ACI needs to pull from ACR. Giving ACI a UAMI + `AcrPull` avoids embedding registry usernames/passwords in the container group definition.

## Real-life example

A **reusable contractor badge** kept in the equipment cage. Any machine (container group) that wears the badge can open the warehouse. If you replace the machine, you keep the same badge.

## Connections in this project

```
UAMI (aci)
  --attached--> azurerm_container_group.backend
  --role AcrPull--> ACR
  --> backend container can pull employee-app-backend image
```

## How Terraform creates it

Created in `terraform/modules/aci`, then role assignment + ACI identity block.

## In this project

Identity for private backend image pulls.
