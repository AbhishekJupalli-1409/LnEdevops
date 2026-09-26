# azurerm_subnet_nat_gateway_association

## Introduction

Binds a NAT Gateway to a **specific subnet**. Only that subnet’s outbound traffic uses the NAT.

## Why we use it

We do not want every subnet forced through the agent NAT. AKS has its own outbound via Azure Load Balancer profile; only `snet-agent` needs this NAT pattern for the VM.

## Real-life example

Turning on “shared outbound dock” for the **technician workshop floor only**, not for the records archive or shop floor.

## Connections in this project

```
snet-agent --NAT assoc--> nat-agent --PIP--> Internet
```

## How Terraform creates it

```hcl
resource "azurerm_subnet_nat_gateway_association" "agent" {
  subnet_id      = azurerm_subnet.agent.id
  nat_gateway_id = azurerm_nat_gateway.agent.id
}
```

## In this project

Completes agent outbound connectivity without public NIC IPs.
