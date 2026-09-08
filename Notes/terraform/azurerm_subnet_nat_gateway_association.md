# azurerm_subnet_nat_gateway_association

## Brief introduction

Attaches a NAT Gateway to a subnet so VMs/NICs in that subnet use it for outbound traffic.

## Why we create it

Only the agent subnet should egress via this NAT (not the whole VNet by accident).

## How Terraform creates it

```hcl
resource "azurerm_subnet_nat_gateway_association" "agent" {
  subnet_id      = azurerm_subnet.agent.id
  nat_gateway_id = azurerm_nat_gateway.agent.id
}
```

## Use in this project

Wires `snet-agent` → `nat-agent`.

## Example to understand

Turning on “use shared exit” for one floor of the building only.
