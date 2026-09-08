# azurerm_network_interface

## Introduction

A **NIC** attaches a VM to a subnet and provides a private IP. Optionally it can reference a public IP — **not here**, because policy denies public IPs on NICs.

## Why we use it

Every Azure VM needs a NIC. For the agent, the NIC must be on `snet-agent` with private IP only so the VM can reach private AKS and egress via NAT.

## Real-life example

The technician’s **desk network jack** on the workshop floor — internal network only, no personal public doorbell.

## Connections in this project

```
snet-agent --> NIC (private IP) --> Agent VM
NIC has NO public_ip_address_id
Outbound: subnet NAT Gateway
Inbound from Internet: none (by design)
East-west: can reach private AKS API / other VNet services allowed by NSG
```

## How Terraform creates it

```hcl
resource "azurerm_network_interface" "agent" {
  # ip_configuration { subnet_id = agent_subnet; private IP }
}
```

## In this project

Network identity of the self-hosted Azure DevOps agent.
