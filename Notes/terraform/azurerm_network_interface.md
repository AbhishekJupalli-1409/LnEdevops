# azurerm_network_interface

## Brief introduction

A **NIC** connects a VM to a subnet (private IP). Optionally can have public IPs (blocked here by policy).

## Why we create it

The agent VM needs a private IP in `snet-agent` with **no** public IP.

## How Terraform creates it

```hcl
resource "azurerm_network_interface" "agent" {
  name                = "nic-agent"
  # ip_configuration with subnet_id, private_ip only — no public_ip_address_id
}
```

## Use in this project

Network attachment for the self-hosted Azure DevOps agent.

## Example to understand

Ethernet jack on the agent desk — internal network only.
