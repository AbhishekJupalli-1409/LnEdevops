# azurerm_linux_virtual_machine

## Brief introduction

An Azure **Linux VM** — IaaS compute you manage (OS, agents, tools).

## Why we create it

Private AKS API is unreachable from Microsoft-hosted pipeline agents. A VM **inside the VNet** runs `kubectl` / `helm` / `flux` jobs on pool `empapp-private-pool`.

## How Terraform creates it

```hcl
resource "azurerm_linux_virtual_machine" "agent" {
  name                = "vm-azdo-agent"
  size                = "Standard_B2s"
  network_interface_ids = [azurerm_network_interface.agent.id]
  # Ubuntu 22.04, SSH with tls_private_key public key
}
```

## Use in this project

Self-hosted AzDO agent for ingress Helm + Flux bootstrap pipelines.

## Example to understand

A worker sitting inside the locked building who can talk to the private Kubernetes API, while cloud workers outside cannot.
