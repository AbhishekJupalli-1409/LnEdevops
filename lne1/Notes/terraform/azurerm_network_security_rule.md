# azurerm_network_security_rule

## Introduction

One **rule** inside an NSG: priority number, direction (in/out), allow/deny, protocol, ports, source/destination prefixes.

Lower priority number = evaluated earlier.

## Why we use it

Express the exact contract: “Only the AKS subnet may open TCP to the backend container port.” Then a broader deny catches mistakes.

## Real-life example

Building policy sheet:

1. Rule 100: Allow cafeteria deliveries from employee wing, door #3000.  
2. Rule 200: Deny all other inbound deliveries.

## Connections in this project

```
Source: AKS subnet CIDR
Dest:   ACI subnet
Port:   backend_container_port (e.g. 3000)
  --> enables Frontend --> API private calls

Without Allow rule, frontend would time out talking to ACI even though both are "in the VNet."
```

## How Terraform creates it

```hcl
resource "azurerm_network_security_rule" "aci_allow_from_aks" { ... }
resource "azurerm_network_security_rule" "aci_deny_all_other_inbound" { ... }
```

## In this project

Implements least-privilege east-west traffic for the employee API.
