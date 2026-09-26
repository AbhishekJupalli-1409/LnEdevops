# Credentials document

Same idea as the first project's `docs/CREDENTIALS_TEMPLATE.md`. Terraform apply is what creates the real values. This file lists them so you know where each one lives. It does not contain a password, because none has been generated until you apply.

After a successful infra apply, from a machine that can read the state storage account and Key Vault:

```bash
cd terraform/envs/centralindia
terraform init \
  -backend-config="resource_group_name=rg-voteapp-tfstate-cin" \
  -backend-config="storage_account_name=tfstatevote3gwpva" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=voteapp.terraform.tfstate"
cd ../../..
bash scripts/generate-credentials-doc.sh
```

That writes `Notes/CREDENTIALS.md`. That file is gitignored. Do not commit it.

| Item | Where it actually lives | Notes |
|---|---|---|
| Resource group name | Terraform output `resource_group_name` | `rg-voteapp-centralindia` |
| ACR name and login server | Terraform outputs `acr_name`, `acr_login_server` | Basic SKU, admin user disabled. No registry password. |
| AKS cluster | Terraform output `aks_name` | Private API. Kubeconfig comes from `az aks get-credentials` on the agent VM. |
| MySQL server FQDN | Terraform output `mysql_fqdn` and Key Vault secret `mysql-fqdn` | Resolves to the private endpoint inside the VNet |
| MySQL database | Terraform output `mysql_database_name` and Key Vault secret `mysql-database-name` | `voting` |
| MySQL admin login | Key Vault secret `mysql-admin-user` | default `voteadmin` |
| MySQL admin password | Key Vault secret `mysql-admin-password` | `random_password` at apply time. Not in git. |
| Key Vault name | Terraform output `key_vault_name` | `kv-voteapp-<suffix>` |
| Agent VM private IP | Terraform output `agent_private_ip` | subnet `10.20.4.0/24`, no public IP on the NIC |
| Agent VM SSH private key | Key Vault secret `agent-vm-ssh-private-key` | break-glass. Normal access is `az vm run-command` as `azureagent`. |
| Azure DevOps PAT | Variable group `voteapp-shared-vars`, secret `azdoPersonalAccessToken` | You create this token. Terraform does not invent it. |
| ARM service connection | Azure DevOps, name `voteapp-arm` | The app registration secret lives in Azure DevOps, not in this repo. |
| ACR service connection | Azure DevOps, name `voteapp-acr` | Uses Azure AD. There is no ACR admin password. |
