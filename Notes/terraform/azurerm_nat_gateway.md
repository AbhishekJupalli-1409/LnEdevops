# azurerm_nat_gateway

## Brief introduction

**NAT Gateway** gives private subnets SNAT outbound internet access through one or more public IPs.

## Why we create it

Agent VM has no public IP but must reach Azure DevOps, package mirrors, etc.

## How Terraform creates it

```hcl
resource "azurerm_nat_gateway" "agent" {
  name                    = "nat-agent"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}
```

Paired with `azurerm_nat_gateway_public_ip_association` and `azurerm_subnet_nat_gateway_association`.

## Use in this project

Outbound-only path for `snet-agent`.

## Example to understand

Private phones calling out through one office landline number — callers outside cannot dial individual phones.
