# azurerm_nat_gateway_public_ip_association

## Introduction

This association resource attaches a public IP (or prefix) to a NAT Gateway. Until associated, the NAT Gateway has no outbound address to use.

## Why we use it

Terraform models Azure’s link between NAT and PIP explicitly so dependencies are clear and destroy order is safe.

## Real-life example

Plugging the **phone company’s copper pair** into your PBX. The PBX exists, the phone number exists — association connects them.

## Connections in this project

```
azurerm_public_ip.nat  --associates-->  azurerm_nat_gateway.agent
```

Together with subnet association, agent subnet traffic can egress.

## How Terraform creates it

```hcl
resource "azurerm_nat_gateway_public_ip_association" "agent" {
  nat_gateway_id       = azurerm_nat_gateway.agent.id
  public_ip_address_id = azurerm_public_ip.nat.id
}
```

## In this project

Part of the three-piece NAT setup: gateway + PIP association + subnet association.
