# Pipeline: infra Terraform

**File:** `pipelines/infra-terraform-azure-pipelines.yml`

## Introduction

This pipeline runs Terraform against `terraform/envs/centralindia`: download Terraform, `init` with remote state, `validate`, `plan`, then a **gated** `apply` (environment approval).

It creates or updates almost all Azure resources in the architecture diagram: policy, networking, ACR, private AKS, Postgres, Key Vault, ACI, agent VM, and optionally Azure DevOps wiring.

## Why we use it

Infrastructure should change through reviewed automation, not only laptop applies. The plan stage shows the diff; the apply stage requires approval (`empapp-infra-production`), mirroring real change management.

It can run on `ubuntu-latest` because it talks to **Azure Resource Manager APIs**, not to the private Kubernetes API.

## Real-life example

A **city construction permit workflow**:

1. Architects submit blueprints (PR / terraform change).  
2. Planning office prints a diff of what will be built (`terraform plan`).  
3. Inspector signs off (environment approval).  
4. Crews build (`terraform apply`).  

They do not need to enter the finished mall’s locked manager office; they work through city permitting systems (ARM).

## Connections

```
Prerequisite: bootstrap Storage Account/container (remote state)

Pipeline uses:
  - ARM service connection
  - empapp-shared-vars (state RG/account/container, AzDO PAT, ...)

Creates/updates:
  - Policy, VNet/subnets/NSG/NAT/DNS
  - ACR, AKS (+ AcrPull), Postgres (+ DB), Key Vault (+ PE + secrets)
  - ACI backend (+ UAMI + AcrPull)
  - Agent VM (+ run command → private pool agent Online)
  - optional AzDO project/endpoints/pipelines

Enables next steps:
  - App pipelines can push to ACR
  - Private-pool pipelines can reach AKS API via Agent VM
```

## How it works (shape)

- Trigger: `main` + path `terraform/**`  
- Stage Plan on `ubuntu-latest`  
- Stage Apply with environment gate  

## Cheapest / free-tier settings (and what is *not* free)

To keep this learning stack as small as possible:

- **AKS**: `sku_tier = "Free"` (control plane is free), `node_count = 1`,
  `node_vm_size = "Standard_D2s_v3"`. Note: **B-series (burstable) VMs are
  not allowed for AKS system node pools** — they fail with
  `SystemPoolSkuTooLow`, so a small D-series is the cheapest *valid* size.
- **PostgreSQL**: `B_Standard_B1ms` (smallest burstable), 32 GB storage.
  With VNet integration you **must** set `public_network_access_enabled =
  false`, or Azure returns
  `ConflictingPublicNetworkAccessAndVirtualNetworkConfiguration`.
- **ACR**: Basic SKU. **Key Vault**: standard. **ACI**: 1 vCPU / 1.5 GB.
- **Policy assignments** are off by default (`enable_policy_assignments =
  false`) so a service principal without *Resource Policy Contributor* can
  still apply (avoids the `policyAssignments/write` 403). Once that role is
  granted you can set it `true`; the Require-a-tag Deny policies then exempt
  AKS's managed `MC_...` resource group (`excluded_scopes`), because AKS
  creates its VMSS / load-balancer / public IP there untagged and would
  otherwise be blocked with `RequestDisallowedByPolicy`.

Genuinely-free Azure services do **not** cover AKS nodes, the agent VM, the
NAT gateway, or Postgres Flexible Server — these always bill something even
at the smallest size. The settings above just minimise that spend.

## In this project

Primary “build the cloud” automation; see also `docs/RUNBOOK.md` step 1.

## Free / learning subscription tips

- Defaults target cheap SKUs: AKS Free + 1× `Standard_B2ts_v2`, ACR Basic, Postgres `B_Standard_B1ms`, agent `Standard_B1s`.
- Set `enable_policy_assignments = false` in `terraform.tfvars` until the pipeline service principal has **Resource Policy Contributor** (otherwise `policyAssignments/write` returns 403).
- Postgres with VNet integration must set `public_network_access_enabled = false` (already in the module).
