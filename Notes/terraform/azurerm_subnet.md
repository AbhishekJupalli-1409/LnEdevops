# azurerm_subnet

## Introduction

A **subnet** is a CIDR slice of a VNet reserved for a purpose. Some Azure services require a **delegated** subnet (the subnet is reserved so that service can inject network interfaces).

## Why we use it

Mixing AKS nodes, databases, and agent VMs in one flat subnet makes NSG rules messy and breaks service requirements (ACI and Postgres Flexible Server need delegation). Separate subnets give clear blast boundaries and correct platform plumbing.

## Real-life example

Campus **buildings / floors**:

| Subnet | Floor analogy |
|--------|----------------|
| snet-aks | Customer-facing shop floor + private manager office (API) |
| snet-aci | Back-office API room |
| snet-postgres | Records archive (staff only) |
| snet-pe | Vault tunnel room |
| snet-agent | On-site technician workshop with outbound loading dock (NAT) |

Delegation is like leasing an entire floor exclusively to one vendor (Postgres or ACI) so they can install their equipment.

## Connections in this project

```
snet-aks       <-- AKS node pool
snet-aci       <-- azurerm_container_group (backend)
                 <-- NSG: allow from AKS CIDR on backend port
snet-postgres  <-- azurerm_postgresql_flexible_server (delegated)
snet-pe        <-- azurerm_private_endpoint (Key Vault)
snet-agent     <-- Agent VM NIC
                 <-- NAT Gateway association (outbound)
```

**Important design note:** Postgres uses **VNet integration** (delegated subnet), not “public server + Private Endpoint.” That keeps **zero public path** to the database (see architecture notes).

## How Terraform creates it

Five `azurerm_subnet` resources in `terraform/modules/networking`, with `delegation` blocks on ACI and Postgres.

## In this project

Foundation for every private data path in the diagram.
