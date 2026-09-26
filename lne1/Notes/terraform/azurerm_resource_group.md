# azurerm_resource_group

## Introduction

An Azure **resource group (RG)** is a logical container for related resources. Almost every Azure resource must belong to one. You can apply tags, lock it, view costs, and delete the whole group when a project ends.

It does **not** provide networking isolation by itself — that is the VNet’s job. The RG is about **lifecycle and organization**.

## Why we use it

Without resource groups, dozens of AKS, NIC, NSG, and Key Vault objects become hard to find, bill, and tear down. Policies and tags are also easier to manage when resources share an RG.

In this project we need:

- One RG for **platform** resources (apps infra).
- One RG for **Terraform remote state** storage (bootstrap), so state survives even if you recreate the platform RG carefully.

## Real-life example

Think of a **project binder** or **warehouse aisle labeled “Employee Platform”**.

- Every box (AKS, ACR, VM, database) for that project goes on that aisle.
- When the project is cancelled, facilities can clear the whole aisle instead of hunting boxes across the building.
- Cost accounting can say “how much did aisle EmpApp cost this month?”

The binder is not a locked room (security); it is an organizational shelf.

## Connections in this project

```
azurerm_resource_group.this
   ├── networking (VNet, subnets, NSG, NAT, private DNS)
   ├── ACR
   ├── AKS
   ├── PostgreSQL
   ├── Key Vault + Private Endpoint
   ├── ACI backend
   └── Agent VM

azurerm_resource_group.state (bootstrap)
   └── Storage Account + tfstate container  --> used by env Terraform backend
```

Tags `Business Unit` and `Cost Center` on the RG help satisfy subscription policy that requires those tags on resources.

## How Terraform creates it

**Platform** — `terraform/envs/centralindia/main.tf`:

```hcl
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}
```

**Bootstrap** — `terraform/bootstrap/main.tf` creates `azurerm_resource_group.state` for remote state only.

## In this project

| Instance | Role |
|----------|------|
| `this` | Main platform RG in Central India |
| `state` | Holds Terraform state storage account |
