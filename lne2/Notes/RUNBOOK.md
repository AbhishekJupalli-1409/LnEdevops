# Runbook — voting app, from an empty subscription to a working site

Do the steps in order. Each step ends with **what you must see in the UI** before you continue. If that check fails, stop and fix it. Later steps fail for a confusing reason.

This repository **is** the `lne2` folder. When you push, the Git root contains `pipelines/`, `terraform/`, `patches/`, and `gitops/` directly. There is no `lne2/` prefix in Azure DevOps paths.

The Azure DevOps **organization** is the only thing you create by hand. The project, pool, service connections, and variable group are also created in the Azure DevOps UI, because a pipeline cannot log in until those exist. Every Azure resource after that (resource group, VNet, NAT, ACR, AKS, MySQL, Key Vault, private endpoints, agent VM) is created by Terraform.

Names used below match the YAML defaults. If you rename one, change it everywhere it appears.

| Name | Where it is set |
|---|---|
| Azure DevOps org | `https://dev.azure.com/<your-org>` |
| Project | the project that holds this git repo |
| ARM service connection | `voteapp-arm` |
| ACR service connection | `voteapp-acr` |
| Variable group | `voteapp-shared-vars` |
| Agent pool | `voteapp-private-pool` |
| Resource group | `rg-voteapp-centralindia` |
| AKS | `aks-voteapp-cin` |
| Apply environment | `voteapp-infra-production` |

This stack requires the tags `Department` and `Project Code` on resources it creates. Do not reuse `rg-empapp-centralindia` or the empapp ACR names.

---

## 0. Azure subscription and CLI

1. In the [Azure portal](https://portal.azure.com) confirm you can see the subscription you will deploy into. Copy **Subscription ID** and **Tenant ID** (Microsoft Entra ID → Overview).
2. On your laptop:

```bash
az login
az account set --subscription "<subscription-id>"
az account show --query "{name:name, id:id}" -o table
terraform version    # need >= 1.6
```

**UI check:** Azure portal → the subscription → your user has **Owner**, or **Contributor** plus **User Access Administrator**. Without User Access Administrator, Terraform cannot create the AcrPull and Key Vault role assignments. To assign the policies in step 6 you also need **Resource Policy Contributor** (Owner includes it).

---

## 1. Azure DevOps organization and project

Terraform does not create the organization.

1. Open [https://dev.azure.com](https://dev.azure.com) and create an organization if you do not have one. Reusing the organization from the first project is fine.
2. Inside it, use the project that already contains this repo, or create one (for example `learnandearn`).
3. Push this repository so **Repos** contains the `lne2` folder.

**UI check**

- The browser URL looks like `https://dev.azure.com/<org>/<project>`.
- **Repos** shows `pipelines/`, `terraform/`, `patches/`, and `gitops/` at the root of the repo.
- Write the org URL down with no project path: `https://dev.azure.com/<org>`. That value is `azdo_org_service_url`.

---

## 2. Personal access token

User menu (top right) → **Personal access tokens** → **New token**.

| Field | Value |
|---|---|
| Organization | this org |
| Scopes | **Custom defined** |
| Agent Pools | Read & manage |
| Code | Read & write (Flux bootstrap pushes its install manifests) |

Copy the token once. You will not see it again.

Do **not** paste it into `terraform.tfvars`. Do not set `azdo_personal_access_token = ""` there either. An empty value in that file overrides the pipeline secret and the agent VM registers with a blank token.

**UI check:** the token is listed and not expired. Scopes show Agent Pools and Code.

---

## 3. Agent pool (empty is correct)

The VM created later joins this pool. The pool must exist **before** `terraform apply`, or the install script fails with "pool not found".

1. **Project settings** (bottom left) → **Agent pools** → **Add pool**.
2. Pool type: **Self-hosted**. Pool to link: **New**. Name: `voteapp-private-pool`.
3. Grant access permission to all pipelines.
4. Open the pool. It has no agents yet.

**UI check:** Organization settings or Project settings → Agent pools → `voteapp-private-pool` exists and the agent list is empty.

---

## 4. ARM service connection

This is the identity Terraform and `az aks` / `az keyvault` use. It is not an Azure DevOps login.

1. **Project settings** → **Service connections** → **New service connection** → **Azure Resource Manager**.
2. Choose the recommended identity (app registration / workload identity, or service principal manual) that can use your subscription.
3. Scope: **Subscription**. Pick the subscription from step 0.
4. Service connection name: `voteapp-arm`.
5. Grant access permission to all pipelines.

The app registration needs **Contributor** and **User Access Administrator** on the subscription (or Owner). Add **Resource Policy Contributor** if you will create the policy assignments.

**UI check:** Service connections lists `voteapp-arm`. Open it. The subscription id matches step 0. **Verify** succeeds.

---

## 5. Remote state (once, from your laptop)

Terraform cannot store state in a storage account that does not exist yet. This step uses local state and creates only the state account.

```bash
cd terraform/bootstrap
terraform init
terraform apply
terraform output
```

Copy `resource_group_name`, `storage_account_name`, `container_name`, and `state_key`.

**UI check:** Azure portal → resource group `rg-voteapp-tfstate-cin` → a storage account whose name starts with `tfstatevote` → Containers → `tfstate`. Location is **Central India**. The resource group tags include `Department` and `Project Code`.

---

## 6. Variable group and tfvars

1. **Pipelines** → **Library** → **+ Variable group**. Name: `voteapp-shared-vars`.
2. Allow access to all pipelines.
3. Add these variables:

| Name | Secret? | Value |
|---|---|---|
| `tfStateResourceGroup` | no | resource group from step 5 |
| `tfStateStorageAccount` | no | storage account from step 5 |
| `tfStateContainer` | no | `tfstate` |
| `azdoPersonalAccessToken` | **yes** | the PAT from step 2 |

4. Copy `terraform/envs/centralindia/terraform.tfvars.example` to `terraform.tfvars` on the machine only if you apply from the laptop. Fill `subscription_id` and `tenant_id`. Do not commit `terraform.tfvars`. The infra pipeline does not read that file for the PAT. It sets `TF_VAR_azdo_personal_access_token` from the secret above.
5. If `azdo_org_service_url` in `variables.tf` is not your org, set it in `terraform.tfvars` (no trailing slash, no project name).

**UI check:** Library → `voteapp-shared-vars` shows the three state variables in clear text and `azdoPersonalAccessToken` as a lock icon.

---

## 7. Infra pipeline

1. **Pipelines** → **New pipeline** → your repo → **Existing Azure Pipelines YAML file**.
2. Path: `/pipelines/infra-terraform-azure-pipelines.yml`.
3. The parameter **Azure Resource Manager service connection name** must be exactly `voteapp-arm` (or whatever you named the connection in step 4). A wrong name fails at compile time.
4. Save and run.

The Plan stage runs `terraform plan` on `ubuntu-latest`. The Apply stage waits on the environment `voteapp-infra-production`. The first run creates that environment. Approve it. Apply creates:

- subscription policy assignments `voteapp-allowed-locations-india`, `voteapp-require-tag-department`, `voteapp-require-tag-project-code`, `voteapp-deny-nic-public-ip`
- resource group `rg-voteapp-centralindia` in **Central India**
- VNet `vnet-voteapp-cin`, subnets `snet-aks`, `snet-pe`, `snet-agent`, NAT `nat-agent`
- ACR `acrvoteapp<suffix>` (Basic, admin disabled)
- private AKS `aks-voteapp-cin` (system pool `Standard_D2s_v3`)
- MySQL Flexible Server `mysql-voteapp-<suffix>` SKU `B_Standard_B1ms`, database `voting`, private endpoint. The provider leaves the server in public-access mode and this stack adds **no firewall rule**, so a connection from the internet is refused. AKS uses the private endpoint.
- Key Vault `kv-voteapp-<suffix>` and the MySQL secrets, plus a private endpoint
- VM `vm-voteapp-agent` (`Standard_B2s_v2`, user `azureagent`, no public IP on the NIC)

**UI check**

- The pipeline is green, including the run-command step that registers the agent.
- Portal → `rg-voteapp-centralindia` → location **Central India**. Every resource shows tags `Department` and `Project Code`.
- AKS → `aks-voteapp-cin` → **Networking** → API server access is **private**.
- MySQL server → **Networking** shows public access **enabled** and a private endpoint. **Networking** → firewall rules is empty (no `0.0.0.0` rule). Database `voting` exists under Databases. Inside the VNet the server name resolves through `privatelink.mysql.database.azure.com` to the private endpoint. The provider in use does not let Terraform turn the public-access flag off; with no firewall rule the internet still cannot log in.
- Key Vault → **Networking** shows a private endpoint. **Secrets** lists `mysql-admin-password`, `mysql-admin-user`, `mysql-database-name`, `mysql-fqdn`, and `agent-vm-ssh-private-key`.
- Virtual machine `vm-voteapp-agent` → Networking → the NIC has a private IP in `10.20.4.0/24` and **no public IP**.
- Agent pools → `voteapp-private-pool` → agent `vm-voteapp-agent` is **Online**.

If policy assignment fails with authorization, the service principal is missing Resource Policy Contributor. Grant it, or set `enable_policy_assignments = false`, apply the rest, grant the role, set it back to `true`, and apply again.

The `MC_rg-voteapp-centralindia_aks-voteapp-cin_centralindia` resource group is exempt from the tag policies. AKS creates untagged node resources there.

Write the credentials file once Apply is green. The template is [CREDENTIALS_TEMPLATE.md](CREDENTIALS_TEMPLATE.md). The script fills `Notes/CREDENTIALS.md` from Terraform outputs and Key Vault. That file is gitignored.

```bash
cd terraform/envs/centralindia
terraform init \
  -backend-config="resource_group_name=<tfStateResourceGroup>" \
  -backend-config="storage_account_name=<tfStateStorageAccount>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=voteapp.terraform.tfstate"
cd ../../..
bash scripts/generate-credentials-doc.sh
```

**UI check:** `Notes/CREDENTIALS.md` exists on your machine and is not in the git commit. Key Vault still shows the five secrets listed above.

---

## 8. ACR service connection

Image push uses a Docker service connection. The connection **name** goes in the YAML. The registry URL inside the connection must be the login server Terraform created (`terraform output acr_login_server`, shape `acrvoteapp<suffix>.azurecr.io`).

1. **Project settings** → **Service connections** → **New** → **Docker Registry** → **Azure Container Registry**.
2. Select the subscription and the `acrvoteapp...` registry from step 7.
3. Name: `voteapp-acr`.
4. Grant access to all pipelines.

The identity behind this connection needs **AcrPush** on that registry. The Azure portal connection wizard grants it when you pick the registry. Admin user on the registry stays **disabled**.

**UI check:** the connection exists. Its registry host matches `acr_login_server` from the apply log. It is not the login server from the first project.

---

## 9. Image pipelines

Create **three** pipelines. Each one builds one image on `ubuntu-latest` (the agent VM has no Docker). Each clones `dockersamples/example-voting-app` and applies only its own patch from `patches/` and `scripts/patch-voting-app.sh`.

| Pipeline YAML | Image |
|---|---|
| `/pipelines/vote-azure-pipelines.yml` | `vote` |
| `/pipelines/worker-azure-pipelines.yml` | `worker` |
| `/pipelines/result-azure-pipelines.yml` | `result` |

1. **Pipelines** → **New pipeline** → Existing Azure Pipelines YAML file. Repeat for each path above.
2. Parameter **ACR Docker service connection name**: `voteapp-acr` on all three.
3. Run all three.

**UI check:** ACR → Repositories shows `vote`, `worker`, and `result`, each with tag `latest`. The vote log contains `patched vote`. The worker log contains `patched worker`. The result log contains `patched result`.

---

## 10. Ingress pipeline

Run this **before** Flux. Flux creates Ingress objects that need the `nginx` ingress class.

1. New pipeline → `/pipelines/nginx-ingress-azure-pipelines.yml`.
2. Service connection parameter: `voteapp-arm`.
3. The pool is `voteapp-private-pool`. A Microsoft-hosted agent cannot reach the private API server.
4. Run it.

**UI check**

- The job ran on `vm-voteapp-agent`, not on Hosted Ubuntu.
- The log prints a Service `ingress-nginx-controller` with an **EXTERNAL-IP**.
- Portal → the `MC_...` resource group → a Public IP address. That address is the site URL. Write it down. It is not the NAT public IP on `pip-nat-agent`.

```text
http://<that-ip>/vote/
http://<that-ip>/result/
```

Those URLs 404 until step 11 finishes. That is expected.

---

## 11. Flux pipeline

1. New pipeline → `/pipelines/flux-bootstrap-azure-pipelines.yml`.
2. Confirm the parameters: service connection `voteapp-arm`, org, project, and repo name. The repo name is the Azure DevOps repo whose **root** is this folder. It is not `example-voting-app`, and the path is not prefixed with `lne2/`.
3. Run it on `voteapp-private-pool`.

The job reads the ACR login server, the MySQL hostname, and the password from Key Vault, writes ConfigMap `cluster-vars` and Secret `voting-db`, then reconciles.

**UI check**

- Flux pushed a commit that adds `gitops/clusters/aks-centralindia/flux-system/`.
- Open `gitops/clusters/aks-centralindia/kustomization.yaml`. It must list both `flux-system` and `apps-kustomization.yaml`. If bootstrap left only `flux-system`, add the second line and push:

```yaml
resources:
  - flux-system
  - apps-kustomization.yaml
```

- On the agent (or from the pipeline log): pods in namespace `voting` are `Running` for `vote`, `result`, `worker`, and `redis`.
- `kubectl -n voting get ingress` shows hosts for `/vote` and `/result`.

The worker and result logs should say they connected to the database. Redis is reachable only from the vote and worker pods (NetworkPolicy). There is no public Service for Redis or the worker.

---

## 12. Browser check

Open the ingress public IP from step 10. Use **http**, not https. This chart does not install a certificate.

1. `http://<ingress-ip>/vote/` shows Cats vs Dogs. The buttons are styled (the `/static` path reached the vote service).
2. Click a side. The page reloads and the choice is marked. A second click can change the vote.
3. `http://<ingress-ip>/result/` shows the bar chart. Within a few seconds the count matches the vote you cast. The result page reads MySQL over the private endpoint. It does not call Redis.

**UI check:** both pages load on that one IP. A vote on `/vote/` changes the numbers on `/result/`.

If `/vote/` is a blank unstyled page, the `/static` ingress did not apply. Re-run the Flux pipeline.

If the vote click returns 404, the form is posting somewhere other than `/vote/`. The image patch sets `action="/vote/"`. Rebuild the vote image (step 9) and re-run Flux.

If `/result/` stays on "No votes yet" and the worker pod is CrashLooping, read `kubectl -n voting logs deploy/worker`. The usual cause is the MySQL password secret missing or the private DNS name not resolving on the node. Confirm Key Vault secret `mysql-fqdn` matches `MYSQL_HOST` in `kubectl -n flux-system get cm cluster-vars -o yaml`, and that the MySQL private endpoint NIC has an IP in `10.20.2.0/24`.

---

## What talks to what, privately

| From | To | Path |
|---|---|---|
| Browser | vote and result | ingress public IP, HTTP 80 only |
| vote pod | Redis | ClusterIP `redis:6379`, allowed by NetworkPolicy |
| worker pod | Redis | same NetworkPolicy |
| worker pod | MySQL | private endpoint, port 3306, DNS zone `privatelink.mysql.database.azure.com` |
| result pod | MySQL | same private endpoint |
| Flux job on the agent VM | Key Vault | private endpoint when the agent resolves the vault name inside the VNet; the password is copied into Secret `voting-db` |

Nothing in this path uses a public IP on a NIC. The NAT gateway is outbound-only for the agent subnet so the VM can register with Azure DevOps and download kubectl, Helm, and Flux.
