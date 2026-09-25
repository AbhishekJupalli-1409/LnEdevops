# Platform reference

## Request path

```text
Browser
  → public IP on the ingress-nginx Service (Azure LB; not a Terraform public IP)
  → node in snet-aks that is running the ingress pod
  → ingress-nginx reads the path
       /emp    → frontend-service → React pod
       /to-do  → todolist-service → Flask pod → SQLite in that container
       /api    → aci-backend Endpoints → ACI private IP :8000 → PostgreSQL
```

`private_cluster_enabled` hides the Kubernetes API only. The LoadBalancer Service still gets a public IP. With `replicaCount: 1` and `externalTrafficPolicy: Local`, the LB sends traffic only to the node that has a Ready ingress pod. kube-proxy on that node delivers to the pod. The LB does not choose `/emp` vs `/api`.

Pod CIDR `10.244.0.0/16` and service CIDR `10.20.0.0/16` are cluster-internal. Azure sees node traffic as `snet-aks`. The ACI NSG allows that subnet to port 8000.

Subnets: `snet-aks` (nodes), `snet-aci` (delegated to Container Instances), `snet-postgres` (delegated to Flexible Server), `snet-pe` (Key Vault private endpoint), `snet-agent` (agent VM, NAT gateway for outbound).

`azurerm_public_ip.nat` is the agent VM's outbound IP. Users never open it.

## Apps

| App | Repo | Data |
|---|---|---|
| React employee UI | `cubastion-training/sample-react-app` | none; calls the API from the browser |
| Node employee API | `cubastion-training/sample-node-app` | PostgreSQL. Pipeline adds `pg` / `pg-hstore` and SSL. `Id` is generated in the Sequelize model. |
| Flask todo | `a7medayman6/Todo-List-Dockerized-Flask-WebApp` (branch `master`) | SQLite file in the container |

Frontend pipeline patches Router `basename="/emp"` before `docker build`. Do not fork the upstream repos.

## Who applies what

| Install | Tool | Where it runs |
|---|---|---|
| Azure resources + agent registration | Terraform | `ubuntu-latest` (ARM) |
| ingress-nginx controller | Helm | private pool |
| frontend, todolist, Ingress rules | Flux | controllers inside AKS, bootstrapped from the private pool |

`gotk-components.yaml` is the Flux install. `gotk-sync.yaml` is the GitRepository plus the Kustomization that syncs `gitops/clusters/aks-centralindia`. `apps-kustomization.yaml` applies `apps/` and substitutes `cluster-vars` (`ACR_LOGIN_SERVER`, `BACKEND_PRIVATE_IP`, `BACKEND_PORT`).

## Pipeline order

1. PAT (Agent Pools Read & manage, Code Read). Pool `empapp-private-pool` exists and is empty.
2. Service connection `empapp-arm`. Variable group with `tfStateResourceGroup`, `tfStateStorageAccount`, `tfStateContainer`, secret `azdoPersonalAccessToken`.
3. `terraform/bootstrap` apply. Put the storage account name into the variable group.
4. Infra pipeline. Environment `empapp-infra-production` must exist.
5. Confirm agent **Online**.
6. Docker Registry service connection aimed at the live ACR. Set `acrServiceConnection` and `acrLoginServer`.
7. Three image pipelines on `ubuntu-latest`. Confirm the three repositories exist in ACR.
8. Infra apply again so ACI can pull `employee-app-backend:latest`.
9. Ingress pipeline on the private pool. Copy `Ingress public IP`.
10. `frontend_origin = "http://<ip>"` and infra apply again.
11. Flux pipeline on the private pool. Parameters: real org/project/repo, live ACR login server, ACI private IP.

## Failures already seen

| Log | Cause |
|---|---|
| Module incompatible with count | `azuredevops` module used to embed `provider "azuredevops"`. Provider stays in the root module. |
| Not authorized to access Azure DevOps organization | Provider runs on every plan. PAT missing, empty in tfvars, or placeholder. ARM service principal is not an Azure DevOps login. |
| `az account clear` / script exit 1 | Cleanup after failure. The Terraform `Error:` is above that line. |
| InaccessibleImage `employee-app-backend:latest` | Image not in this ACR yet, or the service connection pushed to a different registry. |
| Pool already contains agent `vm-empapp-agent` | Previous registration still in the pool. Delete it, then re-apply the run-command. |
| Policy assignment already exists | Subscription assignments from an earlier run. Keep `enable_policy_assignments = false` or import them. |
| `lookup ... on 127.0.0.53:53: no such host` during docker push | Service connection registry hostname is not the live `*.azurecr.io` login server. |
| Helm wait timeout on ingress | Job not on the private pool, or the agent is offline. |
| Employee API CORS failure | `frontend_origin` does not exactly match `http://<ingress-ip>`. |
| `/emp` blank page | Image built without the basename patch, or Flux has not applied the frontend Deployment. |
