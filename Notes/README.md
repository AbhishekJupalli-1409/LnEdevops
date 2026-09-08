# LearnAndEarn — Notes

Learning notes for this project's Azure platform: **why** each piece exists, **how** Terraform (or pipelines/GitOps) creates it, a short intro, and a small example.

## Project in one line

Private Azure stack for Employee App + Todo List: Terraform builds the cloud, Azure Pipelines build/push images and install ingress/Flux, Flux GitOps deploys frontend + todolist on private AKS, and the Node backend runs on private ACI talking to private PostgreSQL.

## Folder layout

| Folder | Contents |
|--------|----------|
| [terraform/](terraform/) | One note per Terraform resource type used in this repo |
| [pipelines/](pipelines/) | Azure DevOps pipelines |
| [gitops/](gitops/) | Helm ingress, Flux GitOps, Kubernetes manifests |

## Suggested reading order

1. [00-platform-overview.md](00-platform-overview.md)
2. Terraform bootstrap resources → networking → ACR/AKS/Postgres → agent VM → Key Vault → ACI → Azure DevOps
3. [pipelines/](pipelines/) then [gitops/](gitops/)
