# LearnAndEarn — Notes

Learning notes for this Azure platform: **what** each piece is, **why** it exists, a **real-life analogy**, **how it connects** to other resources, and **how** Terraform / pipelines / GitOps create it.

## Project in one line

Private Azure stack for Employee App + Todo List: Terraform builds the cloud, Azure Pipelines build/push images and install ingress/Flux, Flux GitOps deploys frontend + todolist on private AKS, and the Node backend runs on private ACI talking to private PostgreSQL.

## Architecture diagram

- [architecture-diagram.png](architecture-diagram.png) — cloud architecture image  
- [architecture-diagram.svg](architecture-diagram.svg) — editable vector version  
- [architecture-diagram.html](architecture-diagram.html) — view SVG in a browser  

## Folder layout

| Folder | Contents |
|--------|----------|
| [00-platform-overview.md](00-platform-overview.md) | End-to-end story, mall analogy, traffic + deploy flows |
| [terraform/](terraform/) | One elaborated note per Terraform resource type |
| [pipelines/](pipelines/) | Each Azure Pipeline + connection chain |
| [gitops/](gitops/) | Helm, Flux, Kustomize, Namespace/Deployment/Service/Ingress |

## Suggested reading order

1. [00-platform-overview.md](00-platform-overview.md) — start here for connections  
2. Architecture diagram (PNG/SVG)  
3. Terraform: bootstrap → networking → ACR/AKS/Postgres → agent → Key Vault → ACI → Azure DevOps  
4. [pipelines/](pipelines/) in runbook order  
5. [gitops/](gitops/) for how apps actually land on AKS  

## Note structure (every resource)

1. **Introduction** — what the technology is  
2. **Why we use it** — problem it solves here  
3. **Real-life example** — analogy outside cloud  
4. **Connections** — what talks to what in this repo  
5. **How it is created** — Terraform / pipeline / YAML  
6. **In this project** — concrete names and paths
