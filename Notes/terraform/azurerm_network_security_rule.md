# azurerm_network_security_rule

## Brief introduction

One allow/deny line inside an NSG (priority, direction, ports, CIDRs).

## Why we create it

Express exact traffic policy for the private backend: AKS → ACI only.

## How Terraform creates it

```hcl
resource "azurerm_network_security_rule" "aci_allow_from_aks" {
  name                        = "AllowFromAks"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = var.aks_subnet_cidr
  destination_port_range      = var.backend_port
  # ...
}

resource "azurerm_network_security_rule" "aci_deny_all_other_inbound" {
  priority = 200
  access   = "Deny"
  # deny other inbound
}
```

## Use in this project

Hardens `snet-aci` so frontend pods can reach the Node API privately without exposing ACI publicly.

## Example to understand

“Allow cafeteria traffic from employee floor on door 3000; deny everyone else.”
