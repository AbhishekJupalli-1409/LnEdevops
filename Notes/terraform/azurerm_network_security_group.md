# azurerm_network_security_group

## Brief introduction

An **NSG** is a firewall for subnets (or NICs): allow/deny rules by port, protocol, and source/destination.

## Why we create it

Lock down AKS and ACI subnets — especially so the backend ACI is not open to the world.

## How Terraform creates it

```hcl
resource "azurerm_network_security_group" "aks" { ... }
resource "azurerm_network_security_group" "aci" { ... }
```

Associated via `azurerm_subnet_network_security_group_association`.

## Use in this project

- AKS NSG: default Azure LB / platform-friendly rules.
- ACI NSG: allow only from AKS subnet on the backend port; deny other inbound.

## Example to understand

Building security: AKS floor can talk to backend door on port 3000; strangers at other doors are denied.
