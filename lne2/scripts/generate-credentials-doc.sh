#!/usr/bin/env bash
# Run AFTER terraform apply in terraform/envs/centralindia has succeeded.
# Reads Terraform outputs and Key Vault. Writes Notes/CREDENTIALS.md.
# That file contains live secrets. It is gitignored. Do not commit it.
set -euo pipefail

cd "$(dirname "$0")/../terraform/envs/centralindia"

RG=$(terraform output -raw resource_group_name)
ACR_NAME=$(terraform output -raw acr_name)
ACR=$(terraform output -raw acr_login_server)
AKS=$(terraform output -raw aks_name)
MYSQL_HOST=$(terraform output -raw mysql_fqdn)
MYSQL_DB=$(terraform output -raw mysql_database_name)
KV=$(terraform output -raw key_vault_name)
AGENT_IP=$(terraform output -raw agent_private_ip)

MYSQL_USER=$(az keyvault secret show --vault-name "$KV" --name mysql-admin-user --query value -o tsv)
MYSQL_PASSWORD=$(az keyvault secret show --vault-name "$KV" --name mysql-admin-password --query value -o tsv)

OUT="$(dirname "$0")/../Notes/CREDENTIALS.md"
cat > "$OUT" << DOC
# Generated credentials - $(date -u +%Y-%m-%dT%H:%M:%SZ)

**This file contains live secrets. Do not commit it. Store it in a password
manager and delete the local copy once you have saved it.**

| Item | Value |
|---|---|
| Resource group | $RG |
| ACR name | $ACR_NAME |
| ACR login server | $ACR |
| ACR admin user | disabled (push with the voteapp-acr service connection) |
| AKS cluster | $AKS (private API) |
| MySQL server FQDN | $MYSQL_HOST |
| MySQL database | $MYSQL_DB |
| MySQL admin login | $MYSQL_USER |
| MySQL admin password | $MYSQL_PASSWORD |
| Key Vault | $KV |
| Private agent VM | vm-voteapp-agent |
| Private agent VM private IP | $AGENT_IP |
| Agent OS user | azureagent |

The agent VM SSH private key is the Key Vault secret \`agent-vm-ssh-private-key\`.
It is not printed here. Day-to-day access is \`az vm run-command\`, not SSH.
The NIC has no public IP. \`pip-nat-agent\` is outbound NAT only.

The Azure DevOps PAT is the secret \`azdoPersonalAccessToken\` in the variable
group \`voteapp-shared-vars\`. Terraform does not store that PAT.

Service connection names (not secrets): \`voteapp-arm\`, \`voteapp-acr\`.
Agent pool: \`voteapp-private-pool\`.
DOC

echo "Wrote $OUT"
