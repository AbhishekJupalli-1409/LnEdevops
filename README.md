# Employee App + Todo List platform on Azure

Terraform + Azure DevOps Pipelines + Flux GitOps that stands up the whole
platform in `centralindia` and deploys three apps behind one public ingress
IP: the Employee app (React frontend + Node backend) and the Todo List
(Flask).

## What's here

```
docs/            Runbook + architecture notes + credentials template
terraform/
  bootstrap/     Run once, manually - creates remote state storage
  modules/       policy, networking, acr, aks, aci, postgresql, keyvault,
                 agent-vm, azuredevops
  envs/centralindia/   Root config wiring every module together
pipelines/       7 Azure Pipelines YAML files (see below)
gitops/          Flux repo tree: apps + the shared Ingress
helm/            values.yaml for the ingress-nginx chart
scripts/         bootstrap wrapper + post-deploy credentials doc generator
```

## The 7 pipelines

| File | Runs on | Does |
|---|---|---|
| `pipelines/app-frontend-azure-pipelines.yml`* | Microsoft-hosted | Build + push frontend image |
| `pipelines/app-backend-azure-pipelines.yml`*  | Microsoft-hosted | Patches in `pg`/`pg-hstore`, builds + pushes backend image |
| `pipelines/app-todolist-azure-pipelines.yml`*  | Microsoft-hosted | Build + push Todo List image |
| `pipelines/infra-terraform-azure-pipelines.yml` | Microsoft-hosted | `terraform plan` + gated `apply` for everything in `terraform/` |
| `pipelines/ingress-nginx-helm-azure-pipelines.yml` | **private pool** | Helm-installs ingress-nginx onto the private AKS cluster |
| `pipelines/flux-bootstrap-azure-pipelines.yml` | **private pool** | Bootstraps Flux, deploys frontend + Todo List via GitOps |
| `pipelines/aci-backend-deploy-azure-pipelines.yml` | Microsoft-hosted | Restarts the backend container group after an image/env change |

\* these three live at the **root of each app's own repo** as
`azure-pipelines.yml` (already delivered earlier in this conversation) -
copies are kept here too for completeness of this package.

**Why two pipelines need a private pool:** AKS is deployed as a **private
cluster** (its API server has no public IP), so a Microsoft-hosted agent -
which runs on public Azure infrastructure outside your VNet - physically
cannot reach it. `terraform/modules/agent-vm` creates a small VM inside the
same VNet, with no public IP of its own, that self-registers as an Azure
DevOps agent for exactly the two pipelines that need direct `kubectl`/`helm`
access.

## Order of operations

See **docs/RUNBOOK.md** for the full, step-by-step sequence - infra has a
real dependency order (state bootstrap -> policy/network/compute -> images
-> ingress -> Flux -> backend CORS refresh) that isn't optional.

## Design decisions worth knowing about

- **ACR stays Basic SKU without a Private Endpoint.** Only Premium ACR
  supports Private Link. The task's private-communication requirement is
  scoped to frontend<->backend and backend<->postgres, not image pulls, so
  Basic + Azure AD RBAC (`AcrPull`, no admin user) is the correct fit for
  "use basic SKUs."
- **PostgreSQL uses "Private access (VNet integration)", not the separate
  Private Endpoint feature.** Flexible Server only offers Private Endpoint
  on servers otherwise running in public-access mode. VNet integration
  keeps 100% of database traffic inside the VNet with zero public entry
  point at all, which is the stronger read of "over a private endpoint."
- **The backend needs two small patches to actually work here**, both
  applied outside the original repos (never forked/modified in place):
  1. `sample-node-app` ships only `mysql`/`mysql2`; the backend pipeline
     `npm install`s `pg` + `pg-hstore` into the checkout before `docker
     build`, and `DBDIALECT=postgres` is set at deploy time.
  2. Its `.env` binds the app to `127.0.0.1`, which is unreachable from
     outside its own container. `APPLICATION_HOST=0.0.0.0` is set at
     deploy time to override that.
- **CORS is enforced twice**: the NSG on `snet-aci` only allows inbound
  traffic from `snet-aks` on the backend port (network layer), and the
  app's own `WHITELIST_URLS` env var is set to the ingress public origin
  (application layer).
- **SPA-under-a-subpath caveat**: see the comment at the top of
  `gitops/clusters/aks-centralindia/apps/ingress/ingress.yaml`.

## What I can't do from here

I don't have your Azure subscription, GitHub org, or Azure DevOps
organization, so I can't run `terraform apply` or the pipelines myself -
everything above is real, complete, ready-to-run configuration, but actual
resource creation (and the real secret values that come out of it) only
happens when you or your pipeline runs it. `scripts/generate-credentials-doc.sh`
produces the actual credentials document from your live deployment once you
have - it isn't something I can pre-fill with real values.
