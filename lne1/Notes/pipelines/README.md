# Azure DevOps pipeline notes (elaborated)

Each note covers **what the pipeline does**, **why it exists**, a **real-life analogy**, and **how it connects** to Terraform / ACR / AKS / GitOps.

| Note | YAML file | Agent pool |
|------|-----------|------------|
| [overview.md](overview.md) | — | — |
| [infra-terraform.md](infra-terraform.md) | `infra-terraform-azure-pipelines.yml` | `ubuntu-latest` |
| [app-frontend.md](app-frontend.md) | `app-frontend-azure-pipelines.yml` | `ubuntu-latest` |
| [app-backend.md](app-backend.md) | `app-backend-azure-pipelines.yml` | `ubuntu-latest` |
| [app-todolist.md](app-todolist.md) | `app-todolist-azure-pipelines.yml` | `ubuntu-latest` |
| [ingress-nginx-helm.md](ingress-nginx-helm.md) | `ingress-nginx-helm-azure-pipelines.yml` | **`empapp-private-pool`** |
| [flux-bootstrap.md](flux-bootstrap.md) | `flux-bootstrap-azure-pipelines.yml` | **`empapp-private-pool`** |
| [aci-backend-deploy.md](aci-backend-deploy.md) | `aci-backend-deploy-azure-pipelines.yml` | `ubuntu-latest` |
