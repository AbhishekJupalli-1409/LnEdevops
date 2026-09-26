# azurerm_virtual_machine_run_command

## Introduction

**Run Command** executes a script on a VM through the Azure VM agent channel — no interactive SSH session required from your laptop.

## Why we use it

After the VM exists, we still need: Azure CLI, kubectl, helm, flux, and Azure DevOps agent registration with a PAT and pool name. Automating that in Terraform makes the agent “appear Online” without manual SSH.

## Real-life example

Facilities sends a **setup checklist robot** into a new workshop: install tools, badge into HQ radio (AzDO), start listening for work orders — without the architect flying on-site with a USB stick.

## Connections in this project

```
VM created
  --> run_command script
        --> install tools
        --> register AzDO agent to pool empapp-private-pool using azp_url/token
              --> private-pool pipelines can schedule jobs here
```

Uses secrets/vars: `azdo_org_service_url`, PAT, pool name from Terraform variables / pipeline variable group.

## How Terraform creates it

`azurerm_virtual_machine_run_command.install_agent` in agent-vm module.

## In this project

Hands-free agent bootstrap; wait a few minutes after apply for the agent to show Online.
