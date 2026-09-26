#!/usr/bin/env bash
# Run AFTER `terraform apply` in terraform/envs/centralindia has succeeded.
# Pulls real values (Terraform outputs + live Key Vault secrets) and writes
# a filled-in credentials document. This is the script that actually
# produces the deliverable described in the assignment's last bullet point -
# nothing here is fabricated, it all comes from the real deployment.
set -euo pipefail

cd "$(dirname "$0")/../terraform/envs/centralindia"

RG=$(terraform output -raw resource_group_name)
ACR=$(terraform output -raw acr_login_server)
AKS=$(terraform output -raw aks_cluster_name)
PGHOST=$(terraform output -raw postgres_server_fqdn)
PGDB=$(terraform output -raw postgres_database)
KV=$(terraform output -raw key_vault_name)
ACI_IP=$(terraform output -raw aci_backend_private_ip)
AGENT_IP=$(terraform output -raw agent_vm_private_ip)

PG_ADMIN=$(az keyvault secret show --vault-name "$KV" --name postgres-admin-password --query value -o tsv)
PG_CONN=$(az keyvault secret show --vault-name "$KV" --name postgres-connection-string --query value -o tsv)

OUT="../../../docs/CREDENTIALS.md"
cat > "$OUT" << DOC
# Generated credentials - $(date -u +%Y-%m-%dT%H:%M:%SZ)

**This file contains live secrets. Do not commit it. Store it in a password
manager / secure share and delete the local copy once distributed.**

| Item | Value |
|---|---|
| Resource group | $RG |
| ACR login server | $ACR |
| AKS cluster | $AKS (private) |
| PostgreSQL server FQDN | $PGHOST |
| PostgreSQL database | $PGDB |
| PostgreSQL admin login | pgadmin |
| PostgreSQL admin password | $PG_ADMIN |
| PostgreSQL connection string | $PG_CONN |
| Key Vault | $KV |
| Backend (ACI) private IP | $ACI_IP |
| Private agent VM private IP | $AGENT_IP |

SSH private key for the agent VM is stored in Key Vault as the secret
\`agent-vm-ssh-private-key\` (retrieve with \`az keyvault secret show\`) -
not printed here since it is long-lived and higher-sensitivity than the
rotatable DB password above.
DOC

echo "Wrote $OUT"
