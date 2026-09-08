# azurerm_public_ip

## Brief introduction

A **public IP** is an internet-routable address you can attach to load balancers, NAT gateways, or (when policy allows) NICs.

## Why we create it

The agent subnet needs **outbound** internet (register AzDO agent, pull packages) without putting a public IP on the VM NIC (policy denies public IPs on NICs).

## How Terraform creates it

```hcl
resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-agent"
  allocation_method   = "Static"
  sku                 = "Standard"
  # attached to NAT Gateway, not to the VM NIC
}
```

## Use in this project

Only for the agent **NAT Gateway**. App public access later comes from the AKS ingress LoadBalancer (created by Kubernetes/Helm, not this TF resource).

## Example to understand

NAT public IP = one shared “exit door” for many private VMs. The VM itself has no doorbell on the internet.
