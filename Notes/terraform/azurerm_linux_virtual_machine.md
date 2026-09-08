# azurerm_linux_virtual_machine

## Introduction

An Azure **Linux VM** is IaaS: you choose size/image and manage the OS. Here it runs an Azure DevOps agent plus kubectl/helm/flux tooling.

## Why we use it

**Private AKS API cannot be reached from Microsoft-hosted agents** (they sit on public Azure infrastructure outside your VNet). Any pipeline step that needs `kubectl`, `helm`, or `flux` against this cluster must run on a machine **inside the VNet** — this VM.

## Real-life example

A **resident building engineer** who lives on campus.

External contractors (Microsoft-hosted agents) cannot enter the locked manager’s office (private AKS API). The resident engineer can. They still ship mail out through the loading dock (NAT) to talk to Azure DevOps headquarters.

## Connections in this project

```
Azure DevOps job (pool empapp-private-pool)
  --> runs on this VM
        --> kubectl/helm/flux --> private AKS API
        --> outbound via NAT --> AzDO / GitHub / mirrors

Terraform:
  networking.agent_subnet --> NIC --> VM
  run_command installs agent + tools
  SSH key from tls_private_key
```

Pipelines that **must** use this pool:

- ingress-nginx Helm  
- Flux bootstrap  

Pipelines that use `ubuntu-latest` (ARM/docker only) do **not** need it.

## How Terraform creates it

Ubuntu 22.04 VM in `terraform/modules/agent-vm`, size typically small (e.g. B2s).

## In this project

Bridge between CI/CD and private Kubernetes.
