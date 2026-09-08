# azurerm_subnet

## Brief introduction

A **subnet** carves a CIDR slice of the VNet for a specific purpose. Some Azure services require **delegated** subnets.

## Why we create it

Isolation and service requirements: AKS nodes, ACI, Postgres Flexible Server, Private Endpoints, and the agent VM each need their own subnet.

## How Terraform creates it

Five subnets in `terraform/modules/networking`:

| Name | Role | Special |
|------|------|---------|
| `snet-aks` | AKS nodes | — |
| `snet-aci` | Backend ACI | Delegated to Container Instances |
| `snet-postgres` | Postgres | Delegated to Flexible Servers (VNet integration) |
| `snet-pe` | Private Endpoints | Key Vault PE |
| `snet-agent` | DevOps agent VM | Outbound via NAT |

```hcl
resource "azurerm_subnet" "aci" {
  name                 = "snet-aci"
  # ...
  delegation {
    name = "aci-delegation"
    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
    }
  }
}
```

## Use in this project

Places each workload in the right network segment with NSGs / NAT where needed.

## Example to understand

Delegation is like reserving a parking floor only for a specific service — Postgres Flexible Server “owns” `snet-postgres` and injects itself there (stronger private access than a public server + PE).
