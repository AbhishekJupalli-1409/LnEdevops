# Voting app platform (lne2)

Azure platform for [dockersamples/example-voting-app](https://github.com/dockersamples/example-voting-app). The application source stays on GitHub. This folder holds Terraform, the image pipeline patches, ingress, and Flux manifests.

Read [Notes/architecture.md](Notes/architecture.md) for the request path, then [Notes/RUNBOOK.md](Notes/RUNBOOK.md) and follow it in order.

| Piece | Path |
|---|---|
| Remote state bootstrap | `terraform/bootstrap` |
| Central India stack | `terraform/envs/centralindia` |
| Image builds | `pipelines/vote-azure-pipelines.yml`, `pipelines/worker-azure-pipelines.yml`, `pipelines/result-azure-pipelines.yml` |
| Terraform pipeline | `pipelines/infra-terraform-azure-pipelines.yml` |
| ingress-nginx | `pipelines/nginx-ingress-azure-pipelines.yml` |
| Flux | `pipelines/flux-bootstrap-azure-pipelines.yml` |

Public URLs after ingress has an IP:

- `http://<ingress-ip>/vote/`
- `http://<ingress-ip>/result/`
