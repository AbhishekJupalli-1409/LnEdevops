# Runbook - do these in order

## 0. One-time manual steps (the only things not driven by Terraform)
1. Create the Azure DevOps **organization** (dev.azure.com) - this is the one
   resource Terraform's `azuredevops` provider cannot create itself.
2. Create an Azure AD **app registration** (service principal) with
   Contributor + User Access Administrator (needed for the role assignments
   this project creates) on the target subscription, plus **Resource Policy
   Contributor** at subscription scope (needed for the policy assignments).
   Note its client ID/secret/tenant ID.
3. Create a Personal Access Token in the new org (Agent Pools: read & manage;
   if also using `manage_azure_devops = true`: Project & Team, Service
   Connections, Build - all read & manage).
4. `az login` as a user/principal that can create resource groups and
   storage accounts, then:
   ```
   ./scripts/bootstrap-backend.sh
   ```
   Copy the printed `backend_config_snippet` values - you'll pass them as
   `-backend-config` flags (or paste into `backend.tf`) in every step below.

## 1. Deploy the infrastructure
```
cd terraform/envs/centralindia
cp terraform.tfvars.example terraform.tfvars   # fill in subscription_id, azdo_* values
terraform init -backend-config="resource_group_name=..." -backend-config="storage_account_name=..." -backend-config="container_name=tfstate" -backend-config="key=centralindia.terraform.tfstate"
terraform plan -out=tfplan
terraform apply tfplan
```
Or, once pushed to your repo, run `pipelines/infra-terraform-azure-pipelines.yml`
(it has a manual-approval gate before `apply`).

This creates: the 3 policy assignments, the VNet + 4 subnets + NSGs, ACR,
the private AKS cluster, PostgreSQL Flexible Server + `employeeappdb`, Key
Vault, the ACI backend (will crash-loop until real images exist - that's
expected at this point), and the private agent VM (give it 3-5 minutes to
show up Online in Project Settings > Agent pools).

## 2. Build and push the three images
Run (or push to trigger) each app's own `azure-pipelines.yml`:
- `sample-react-app` -> `employee-app-frontend`
- `sample-node-app` -> `employee-app-backend` (this pipeline patches in
  `pg`/`pg-hstore` automatically - see README)
- `Todo-List-Dockerized-Flask-WebApp` -> `todo-list-app`

## 3. Install ingress-nginx
Run `pipelines/ingress-nginx-helm-azure-pipelines.yml` (pool:
`empapp-private-pool`). When it finishes:
```
az aks get-credentials -g rg-empapp-centralindia -n aks-empapp-cin   # from inside the VNet / the agent VM
kubectl get svc -n ingress-nginx ingress-nginx-controller
```
Note the `EXTERNAL-IP` - this is your public ingress URL.

## 4. Feed the ingress IP back into Terraform (closes the CORS loop)
```
# terraform.tfvars
frontend_origin = "http://<EXTERNAL-IP>"
```
`terraform apply` again (updates the backend's `WHITELIST_URLS`), or run
`pipelines/aci-backend-deploy-azure-pipelines.yml`.

## 5. Deploy the apps via Flux
Set pipeline variables `githubToken`, `githubOrg`, `platformRepoName`,
`aciBackendPrivateIp` (from `terraform output aci_backend_private_ip`), then
run `pipelines/flux-bootstrap-azure-pipelines.yml` (pool:
`empapp-private-pool`). This bootstraps Flux and reconciles
`gitops/clusters/aks-centralindia`, deploying the frontend, Todo List, and
the shared Ingress.

## 6. Verify
```
http://<EXTERNAL-IP>/emp     -> Employee app
http://<EXTERNAL-IP>/to-do   -> Todo List
```
If either app's CSS/JS 404s, see the SPA-subpath caveat at the top of
`gitops/clusters/aks-centralindia/apps/ingress/ingress.yaml`.

## 7. Generate the credentials document
```
./scripts/generate-credentials-doc.sh
```
Writes `docs/CREDENTIALS.md` with real values pulled from Terraform outputs
and Key Vault. Treat it as a secret - don't commit it.
