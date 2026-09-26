# azurerm_subnet_network_security_group_association

## Introduction

Attaches an NSG to a subnet so every NIC in that subnet inherits the rules.

## Why we use it

Rules sitting on an unattached NSG do nothing. Association is the activation step.

## Real-life example

Printing a security policy is useless until you **nail it to the correct floor’s door**.

## Connections in this project

```
NSG aks --assoc--> snet-aks
NSG aci --assoc--> snet-aci
```

## How Terraform creates it

```hcl
resource "azurerm_subnet_network_security_group_association" "aci" {
  subnet_id                 = azurerm_subnet.aci.id
  network_security_group_id = azurerm_network_security_group.aci.id
}
```

## In this project

Activates AKS/ACI firewalling used by the Frontend→Backend path.
