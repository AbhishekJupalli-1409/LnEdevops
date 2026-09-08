# azurerm_nat_gateway

## Introduction

**NAT Gateway** provides scalable SNAT (outbound) for private subnets through associated public IPs. Many private VMs share outbound connectivity without each having a public IP.

## Why we use it

Agent VM must call Azure DevOps to register/listen for jobs, and download tools. With no NIC public IP (policy), NAT Gateway is the compliant egress pattern.

## Real-life example

Office phones with **no direct outside lines**, all dialing out through one **PBX trunk number**. Outside callers cannot dial individual desks through that trunk; desks can still call out.

## Connections in this project

```
Agent VM (private IP)
  --> snet-agent
        --> NAT Gateway
              --> Public IP
                    --> Internet / Azure DevOps

Pipelines on empapp-private-pool run ON this VM,
so they can reach private AKS API while still reaching GitHub/Azure endpoints outbound.
```

## How Terraform creates it

Created in networking module, then linked with public IP association + subnet association resources.

## In this project

Enables the private agent pattern required by private AKS.
