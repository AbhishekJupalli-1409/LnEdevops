# Pipeline: infra Terraform

**File:** `pipelines/infra-terraform-azure-pipelines.yml`

## Brief introduction

Runs `terraform init`, `validate`, `plan`, then a gated `apply` for `terraform/envs/centralindia`.

## Why we create it

Infrastructure as Code should be applied from CI with review (environment `empapp-infra-production`), not only from laptops.

## How it works

- Trigger: changes under `terraform/**` on `main`
- Pool: `ubuntu-latest` (talks to Azure ARM — no need for private AKS)
- Prerequisite: `terraform/bootstrap` already created state storage
- Uses variable group for state account names + AzDO PAT (azuredevops provider / agent registration)

## Use in this project

Creates/updates policies, networking, ACR, AKS, Postgres, Key Vault, ACI, agent VM, optional AzDO resources.

## Example to understand

Like a construction permit process: **plan** shows the blueprint diff; **apply** builds only after approval.
