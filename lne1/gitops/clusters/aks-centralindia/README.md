# Flux GitOps tree for aks-empapp-cin

`flux bootstrap github --path=gitops/clusters/aks-centralindia ...` (see
pipelines/flux-bootstrap-azure-pipelines.yml) creates the `flux-system/`
folder here itself on first run - it is not something to hand-author, so it
is not included in this download.

Layout:
- `kustomization.yaml` - root list for the flux-system Git path: only
  `flux-system/` + `apps-kustomization.yaml` (not `apps/` directly).
- `apps-kustomization.yaml` - a Flux `Kustomization` custom resource that
  points at `./apps` and substitutes `${ACR_LOGIN_SERVER}`,
  `${BACKEND_PRIVATE_IP}` and `${BACKEND_PORT}` from the `cluster-vars`
  ConfigMap (written by the bootstrap pipeline from Terraform outputs,
  since those values don't exist until after `terraform apply`).
- `apps/` - the actual Kubernetes objects: namespace, frontend, todolist,
  backend Service/Endpoints, and Ingress path rules.
