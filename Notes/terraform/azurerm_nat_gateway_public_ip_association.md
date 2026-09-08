# azurerm_nat_gateway_public_ip_association

## Brief introduction

Links a public IP resource to a NAT Gateway so outbound traffic uses that IP.

## Why we create it

NAT Gateway alone has no address until you associate a public IP.

## How Terraform creates it

```hcl
resource "azurerm_nat_gateway_public_ip_association" "agent" {
  nat_gateway_id       = azurerm_nat_gateway.agent.id
  public_ip_address_id = azurerm_public_ip.nat.id
}
```

## Use in this project

Binds `pip-nat-agent` to `nat-agent`.

## Example to understand

Attaching a phone number to the office PBX before anyone can call out.
