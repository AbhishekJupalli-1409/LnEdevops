# Runbook — from an empty subscription to a working site

Do the steps in order. Each step ends with **what you must see in the UI** before you continue. If that check fails, stop and fix it. Later steps will fail for a confusing reason.

Leave `manage_azure_devops = false` in `terraform.tfvars`. This runbook creates the Azure DevOps project, pool, service connection, variable group, and pipelines **in the UI**. Terraform only builds Azure resources and registers the private agent VM.

Names used below match the YAML defaults. If you rename one, change it everywhere it appears.

| Name | Where it is set |
|---|---|
| Azure DevOps org | `https://dev.azure.com/<your-org>` |
| Project | the project that holds this git repo |
| ARM service connection | `empapp-arm` |
| Variable group | `empapp-shared-vars` |
| Agent pool | `empapp-private-pool` |
| Resource group | `rg-empapp-centralindia` |
| AKS | `aks-empapp-cin` |
| Apply environment | `empapp-infra-production` |

---

## 0. Azure subscription and CLI

1. In the [Azure portal](https://portal.azure.com) confirm you can see the subscription you will deploy into. Copy **Subscription ID**.
2. On your laptop:

```bash
az login
az account set --subscription "<subscription-id>"
az account show --query "{name:name, id:id}" -o table
terraform version    # need >= 1.6
```

**UI check:** Azure portal → the subscription → your user or the account you logged in with has **Owner** or **User Access Administrator** plus **Contributor**. Owner is the simple choice for a learning subscription. Without User Access Administrator, Terraform cannot create the AcrPull role assignments.

---

## 1. Azure DevOps organization and project

Terraform cannot create the organization.

1. Open [https://dev.azure.com](https://dev.azure.com) and create an organization if you do not have one.
2. Inside it, create a project (for example `learnandearn`).
3. Push this repository into that project: **Repos → Files**, or import from your existing git remote.

**UI check**

- The browser URL looks like `https://dev.azure.com/<org>/<project>`.
- **Repos** shows this code, including `pipelines/` and `terraform/`.
- Write that URL down. It is `azdo_org_service_url` (`https://dev.azure.com/<org>` with no project path).

---

## 2. Personal access token

User menu (top right) → **Personal access tokens** → **New token**.

| Field | Value |
|---|---|
| Organization | this org, not "All accessible organizations" unless you intend that |
| Scopes | **Custom defined** |
| Agent Pools | Read & manage |
| Code | Read (Flux clones this repo) |

Copy the token once. You will not see it again.

Do **not** paste it into `terraform.tfvars`. An empty `azdo_personal_access_token = ""` in that file overrides the environment variable and the agent VM registers with a blank token.

**UI check:** the token is listed and not expired. Scopes show Agent Pools and Code.

---

## 3. Agent pool (empty is correct)

The VM created later joins this pool. The pool must exist **before** `terraform apply`, or the install script fails.

1. **Project settings** (bottom left) → **Agent pools** → **Add pool**.
2. Pool type: **Self-hosted**. Pool to link: **New**. Name: `empapp-private-pool`.
3. Grant access permission to all pipelines.
4. Open the pool → **Security** → confirm this project is listed.

**UI check:** `empapp-private-pool` exists. Agents tab says **No agents** or **0 online**. That is expected until step 8.

---

## 4. ARM service connection

Pipelines talk to Azure with this connection. The YAML default name is `empapp-arm`. A different name fails at compile time with "service connection could not be found".

1. **Project settings → Service connections → New service connection**.
2. **Azure Resource Manager** → **Service principal (automatic)** is the easiest.
3. Subscription: the same subscription as step 0.
4. Resource group: leave empty (subscription scope). Terraform creates `rg-empapp-centralindia` itself.
5. Service connection name: `empapp-arm`.
6. Grant access permission to all pipelines.

If the wizard offers a manual service principal instead, the app registration needs these roles on the subscription:

- Contributor
- User Access Administrator

**Resource Policy Contributor** is only required if you later set `enable_policy_assignments = true`. The example tfvars leaves that `false`.

**UI check**

- **Service connections** lists `empapp-arm`, status ready.
- Open it → the subscription ID matches `az account show`.
- You do **not** need an ACR connection yet. ACR does not exist.

---

## 5. Variable group

**Pipelines → Library → + Variable group**. Name: `empapp-shared-vars`.

Add these now. ACR values come in step 10, after the registry exists.

| Name | Value | Secret? |
|---|---|---|
| `tfStateResourceGroup` | filled in step 6 (`rg-empapp-tfstate-cin`) | no |
| `tfStateStorageAccount` | filled in step 6 (printed by bootstrap) | no |
| `tfStateContainer` | `tfstate` | no |
| `azdoPersonalAccessToken` | the PAT from step 2 | **yes** (lock icon) |

**Pipeline permissions** on the variable group → open access to all pipelines.

You can save the group with placeholder state names, then edit the two state values immediately after step 6. Do not run the infra pipeline before those three state variables are real.

**UI check:** Library shows `empapp-shared-vars`. The PAT row has a lock icon. Clicking the value shows dots, not the token.

---

## 6. Terraform state storage (once, on your laptop)

Remote state cannot live in a storage account that does not exist yet. This step creates only that account. State stays on your laptop for this one folder.

```bash
cd terraform/bootstrap
terraform init
terraform apply
terraform output
```

Copy `resource_group_name`, `storage_account_name`, and `container_name`.

Paste them into the variable group from step 5:

- `tfStateResourceGroup` = `resource_group_name` (default `rg-empapp-tfstate-cin`)
- `tfStateStorageAccount` = `storage_account_name` (looks like `tfstateempXXXXXX`)
- `tfStateContainer` = `tfstate`

**UI check — Azure portal**

- Resource group `rg-empapp-tfstate-cin` exists in **Central India**.
- It contains one storage account.
- That account → **Containers** → `tfstate` exists and is private.
- Nothing else (no AKS, no VNet) exists yet.

---

## 7. Fill terraform.tfvars

```bash
cd terraform/envs/centralindia
cp terraform.tfvars.example terraform.tfvars
```

Set:

```hcl
subscription_id   = "<subscription id from step 0>"
azdo_org_service_url = "https://dev.azure.com/<your-org>"
azdo_agent_pool_name = "empapp-private-pool"
manage_azure_devops = false
enable_policy_assignments = false
frontend_origin = "http://REPLACE-WITH-INGRESS-PUBLIC-IP"
```

Do **not** add `azdo_personal_access_token`. Export it in the shell when you apply locally:

```bash
export TF_VAR_azdo_personal_access_token='<paste PAT>'
```

The infra pipeline reads the same value from the secret `azdoPersonalAccessToken`.

**UI check:** none. Confirm the file is not committed if it contains your real subscription id and you do not want that in git. The PAT must not be in the file at all.

---

## 8. Create the infra pipeline, then apply

### 8a. Pipeline and environment in Azure DevOps

1. **Pipelines → Environments → New environment**. Name: `empapp-infra-production`. Resource: **None**.
2. Open the environment → **Approvals and checks → Approvals** → add yourself. Apply will wait here. That is intentional.
3. **Pipelines → New pipeline → Azure Repos Git** → this repo → **Existing Azure Pipelines YAML file**.
4. Branch `main`. Path: `/pipelines/infra-terraform-azure-pipelines.yml`.
5. On the run screen, parameter **Azure Resource Manager service connection name** must be `empapp-arm`.
6. Save / run.

**UI check before the first run**

- Environments lists `empapp-infra-production`.
- The new pipeline's YAML path is `pipelines/infra-terraform-azure-pipelines.yml`.
- The variable group is linked (the YAML references `empapp-shared-vars`; the first run will ask to **permit** the pipeline to use the group and the service connection — click Permit).

### 8b. What a good run looks like

Stage **Plan** (Microsoft-hosted `ubuntu-latest`) must finish green: `terraform init` and `terraform plan`.

Stage **Apply** waits on the environment approval. Review the plan, then approve.

The plan creates, among other things: resource group, VNet and subnets, ACR, private AKS, PostgreSQL, Key Vault, ACI backend, and the agent VM. ACI will restart until the backend image exists (step 10). That is expected.

### 8c. If you apply from the laptop instead

```bash
cd terraform/envs/centralindia
export TF_VAR_azdo_personal_access_token='<PAT>'
terraform init \
  -backend-config="resource_group_name=<tfStateResourceGroup>" \
  -backend-config="storage_account_name=<tfStateStorageAccount>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=centralindia.terraform.tfstate"
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

**UI check — Azure portal** (resource group `rg-empapp-centralindia`)

| Resource | What "good" looks like |
|---|---|
| Virtual network | `vnet-empapp` with subnets including `snet-aks`, `snet-aci`, `snet-postgres`, `snet-agent` |
| AKS `aks-empapp-cin` | **Provisioning state: Succeeded**. Networking shows **private cluster**. You cannot `kubectl` from your laptop. That is correct. |
| Container registry | **SKU Basic**. Admin user **disabled**. Repositories empty until step 10. Copy the **login server** (`*.azurecr.io`). |
| PostgreSQL Flexible Server | **Public access: disabled** (VNet integrated). Database `employeeappdb` exists. |
| Key Vault | Secrets `postgres-admin-password` and `postgres-connection-string` exist after apply. |
| Container instance `aci-empapp-backend` | **Private IP** in `10.x`. State may be **Waiting** or failed pulls until the backend image exists. |
| Virtual machine (agent) | Running, **no public IP** on the NIC. |

**UI check — Azure DevOps → Agent pools → `empapp-private-pool`**

- One agent, name matching the VM, status **Online**.
- This can take 3–5 minutes after apply, because a run-command script installs Azure CLI, kubectl, Helm, Flux, and the Pipelines agent.
- If it stays offline: open the VM in the portal → **Run command** → **RunShellScript** is not something you retype; check the Terraform apply log for `install-devops-agent`. The usual cause is an empty PAT or a pool name that does not match step 3.

**UI check — storage**

- The `tfstate` container now has a blob `centralindia.terraform.tfstate`.

---

## 9. ACR service connection

Image pipelines push with `containerRegistry: $(acrServiceConnection)`.

1. **Project settings → Service connections → New → Docker Registry**.
2. Type: **Azure Container Registry**.
3. Subscription and the registry created in step 8.
4. Name it something stable, for example `acr-empapp`.
5. Grant access to all pipelines.
6. In variable group `empapp-shared-vars` add:

| Name | Value |
|---|---|
| `acrServiceConnection` | `acr-empapp` (the name you just chose) |
| `acrLoginServer` | the login server from the portal, such as `acrempappxxxxx.azurecr.io` |

**UI check:** the Docker Registry connection shows your registry. A test connection succeeds.

---

## 10. Build the three images

Create three pipelines the same way as step 8a, each pointing at a YAML file in **this** repo (the pipelines clone the app repos themselves):

| Pipeline YAML | Image it pushes |
|---|---|
| `pipelines/app-frontend-azure-pipelines.yml` | `employee-app-frontend` |
| `pipelines/app-backend-azure-pipelines.yml` | `employee-app-backend` |
| `pipelines/app-todolist-azure-pipelines.yml` | `todo-list-app` |

Each uses pool **Azure Pipelines / ubuntu-latest** (already in the YAML). Permit the variable group and the ACR connection when Azure DevOps asks.

Run all three. They must finish green.

**UI check — ACR → Repositories**

- `employee-app-frontend` has tags `latest` and a numeric build id.
- `employee-app-backend` the same.
- `todo-list-app` the same.

Then re-run **infra-terraform apply** (or restart is not enough for a new image, because ACI's image is set by Terraform). A second apply pulls `employee-app-backend:latest`.

**UI check — container group `aci-empapp-backend`**

- State **Running**.
- IP address is private (`10.x`), not a public address.
- Events are not stuck on `ImagePullBackOff` or authentication errors.

---

## 11. Install ingress-nginx (private pool)

Create a pipeline for `pipelines/ingress-nginx-helm-azure-pipelines.yml`.

The YAML sets `pool: empapp-private-pool`. Do not switch it to Microsoft-hosted. A Microsoft-hosted agent cannot reach the private AKS API.

Parameter `azureServiceConnection`: `empapp-arm`.

When the job is queued, Azure DevOps may ask to **authorize** the pipeline for the pool. Allow it.

The last step prints `Ingress public IP: 20.x.x.x`. Copy it. No `http://`, no trailing slash, no path.

**UI check**

- The job ran on your agent (agent name on the run page), not `Azure Pipelines`.
- **Azure portal → the AKS node resource group** (name starts with `MC_`) contains a **Public IP** and a **Load balancer**. Terraform did not create this IP. The ingress Service did.
- You still cannot browse a page yet. Flux has not applied the Ingress rules or the app pods.

---

## 12. Tell the backend the public origin (CORS)

Browsers call `http://<that-ip>/api/...`. The Node app only answers if `WHITELIST_URLS` contains that exact origin.

In `terraform.tfvars`:

```hcl
frontend_origin = "http://20.x.x.x"
```

Use the IP from step 11. Scheme `http`, no trailing slash.

Re-run the infra pipeline apply, or locally:

```bash
export TF_VAR_azdo_personal_access_token='<PAT>'
terraform apply -var-file=terraform.tfvars
```

`pipelines/aci-backend-deploy-azure-pipelines.yml` only **restarts** the container group. It does not change `WHITELIST_URLS`. Use Terraform for the origin change.

**UI check:** container group → **Containers → Environment variables** includes `WHITELIST_URLS` equal to `["http://20.x.x.x"]` (the same IP). `DBHOST` is the Postgres hostname, `DBDIALECT` is `postgres`.

---

## 13. Flux (deploy frontend, todo, Ingress rules)

Create a pipeline for `pipelines/flux-bootstrap-azure-pipelines.yml`. Pool is again `empapp-private-pool`.

When you run it, set the parameters (do not leave the samples if they are not yours):

| Parameter | Value |
|---|---|
| `azureServiceConnection` | `empapp-arm` |
| `azdoOrg` | your org name only, not the full URL |
| `azdoProject` | project name |
| `azdoRepo` | git repo name |
| `acrLoginServer` | same as variable `acrLoginServer` |
| `aciBackendPrivateIp` | ACI private IP from the portal or `terraform output aci_backend_private_ip` |

The job uses `azdoPersonalAccessToken` to `flux bootstrap git`. The PAT needs **Code: Read**.

**UI check — pipeline log**

- `flux bootstrap` succeeds and pushes a `flux-system/` folder if it was not already in git.
- `flux reconcile` finishes without a path error.

**UI check — you cannot kubectl from the laptop.** On a later run of this pipeline, or from the agent, these are the healthy signals:

- Namespace `flux-system` has running controllers.
- Namespace `apps` has pods `frontend` and `todolist` **Running**.
- `kubectl get svc -n ingress-nginx ingress-nginx-controller` shows `EXTERNAL-IP` equal to the IP from step 11.
- `kubectl get ingress -n apps` lists `/emp`, `/to-do`, and `/api`.

---

## 14. Browse

Open these in a browser. Replace the IP with yours.

| URL | What you should see |
|---|---|
| `http://<IP>/emp` | Employee app (list / add employee) |
| `http://<IP>/to-do` | Todo list |
| `http://<IP>/api/api/v1/employees/findEmployees` | JSON, not the todo HTML page. The path is `/api` + `/api/v1/employees/...` because the React app appends `/api/v1/employees` to `API_BASE_URL=/api`. |

**If `/emp` is a blank page:** the frontend image was built without the `/emp` router patch. Re-run `pipelines/app-frontend-azure-pipelines.yml` and let Flux pull `:latest` (the pod uses `imagePullPolicy: Always`; restart the deployment if it stays on the old image).

**If the employee list loads but create/list fails in the browser network tab:** CORS. `frontend_origin` must match the address bar origin exactly (`http://` + IP, no slash).

**If `/to-do` works and `/emp` API does not:** Postgres or ACI. Todo does not use Postgres. Check the ACI container is Running and `DBHOST` is set.

**If the agent job never starts:** pool has no **Online** agent, or the pipeline was not granted permission on `empapp-private-pool`.

---

## 15. Credentials sheet (optional)

```bash
cd ~/learnandearn/terraform/envs/centralindia

terraform init -reconfigure \
  -backend-config="resource_group_name=rg-empapp-tfstate-cin" \
  -backend-config="storage_account_name=tfstateemp6yg6h7" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=centralindia.terraform.tfstate"

cd ~/learnandearn
bash ./scripts/generate-credentials-doc.sh
```

From `terraform/envs/centralindia` after a successful apply:

```bash
../../scripts/generate-credentials-doc.sh
```

This writes `docs/CREDENTIALS.md`. Do not commit it.

**UI check:** Key Vault secrets include `postgres-admin-password`, `postgres-connection-string`, and `agent-vm-ssh-private-key`. Day-to-day access to the VM is the portal **Run command**, not SSH.

---

## Order at a glance

```text
Azure login
  → AzDO org, project, git repo
  → PAT
  → empty agent pool empapp-private-pool
  → service connection empapp-arm
  → variable group (state names + PAT)
  → terraform/bootstrap apply          (state storage only)
  → terraform.tfvars, manage_azure_devops = false
  → infra pipeline plan + approved apply
  → portal: RG, AKS private, ACR, Postgres, ACI, VM
  → AzDO: agent Online
  → ACR service connection + variable acrServiceConnection
  → three image pipelines
  → second infra apply so ACI pulls the backend image
  → ingress pipeline on the private pool → copy public IP
  → frontend_origin = http://<IP> → infra apply again
  → flux pipeline on the private pool
  → browser /emp and /to-do
```

## What this runbook deliberately does not do

- It does not set `manage_azure_devops = true`. That mode asks Terraform to create the Azure DevOps project, service connections, and pipelines, and it needs extra PAT scopes plus `azdo_github_org`, a GitHub PAT, and a service principal secret. Use the UI steps above instead.
- It does not expect `kubectl` on your laptop. The AKS API has no public address.
- It does not put the PAT in git.
