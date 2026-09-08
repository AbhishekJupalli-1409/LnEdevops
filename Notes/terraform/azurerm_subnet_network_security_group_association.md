# azurerm_subnet_network_security_group_association

## Brief introduction

Attaches an NSG to a subnet so all NICs in that subnet inherit the rules.

## Why we create it

Rules only take effect after association.

## How Terraform creates it

```hcl
resource "azurerm_subnet_network_security_group_association" "aci" {
  subnet_id                 = azurerm_subnet.aci.id
  network_security_group_id = azurerm_network_security_group.aci.id
}
```

Same pattern for AKS.

## Use in this project

Applies AKS and ACI NSGs to their subnets.

## Example to understand

Hanging the firewall policy sheet on the correct floor’s door.
