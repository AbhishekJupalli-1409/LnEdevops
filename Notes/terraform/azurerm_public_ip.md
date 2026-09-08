# azurerm_public_ip

## Introduction

A **public IP** is an Internet-reachable address in Azure. It can attach to load balancers, application gateways, NAT gateways, or (if policy allows) directly to a NIC.

## Why we use it

Policy **denies public IPs on NICs**, but the agent VM still needs **outbound** Internet (register to Azure DevOps, apt packages, GitHub for Flux). A public IP on a **NAT Gateway** (not on the NIC) solves outbound without exposing inbound SSH on a public address.

Separately, the **app** public IP comes later from Kubernetes (`Service type: LoadBalancer` for ingress-nginx) — that is not this Terraform public IP.

## Real-life example

The workshop has **no street-facing door** (no public IP on the agent NIC). Instead the building has a **shared outbound loading dock number** (NAT public IP). Workers can ship packages out; strangers cannot walk into the workshop from the street using that dock number as a front door.

## Connections in this project

```
azurerm_public_ip.nat
  --> azurerm_nat_gateway_public_ip_association
        --> azurerm_nat_gateway.agent
              --> associated to snet-agent
                    --> Agent VM outbound --> Azure DevOps / Internet

(App public IP)
  Users --> ingress-nginx LB IP  (created by Azure when Helm installs the chart — not this resource)
```

## How Terraform creates it

```hcl
resource "azurerm_public_ip" "nat" {
  name              = "pip-nat-agent"
  allocation_method = "Static"
  sku               = "Standard"
}
```

## In this project

Only for agent NAT egress. Do not confuse with the ingress LB IP printed by the Helm pipeline.
