# Pipelines overview

## Brief introduction

**Azure Pipelines** automate build, push, and deploy steps defined in YAML. This project uses seven pipelines: infra, three apps, ingress Helm, Flux bootstrap, and ACI restart.

## Why we create them

Manual `terraform apply` / `docker build` / `helm install` does not scale and is error-prone. Pipelines give repeatable CI/CD with gates (e.g. Terraform apply environment approval).

## How they relate to Terraform / GitOps

1. **Infra pipeline** applies Terraform (ARM API — works from Microsoft-hosted agents).
2. **App pipelines** build images → ACR.
3. **Ingress + Flux** must run on the **private agent pool** (reach private AKS API).
4. **ACI restart** updates/restarts the private backend when CORS needs the real ingress IP.

## Shared config

- Variable group: `empapp-shared-vars`
- ARM connection: often `empapp-arm`
- Private pool: `empapp-private-pool` (agent VM from Terraform)

## Example flow

```
Push to main (terraform/**) → infra plan → approve → apply
Push app code → build/push image tags to ACR
Run ingress pipeline on private pool → note LB IP
Run flux bootstrap on private pool → apps appear in cluster
Optional: ACI deploy pipeline to refresh backend env
```
