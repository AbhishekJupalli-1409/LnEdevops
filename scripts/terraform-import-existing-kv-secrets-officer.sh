#!/usr/bin/env bash
# Adopt a Key Vault Secrets Officer role assignment that already exists in
# Azure (e.g. granted manually after a 403) but is missing from Terraform
# state. Without this, apply fails with "role assignment already exists".
# Safe to re-run: no-op if already in state or nothing to import.
set -euo pipefail

RG="${RESOURCE_GROUP_NAME:-rg-empapp-centralindia}"
KV_NAME="${KEY_VAULT_NAME:-}"
ADDR="module.keyvault.azurerm_role_assignment.deployer_secrets_officer"
ROLE_NAME="Key Vault Secrets Officer"

if terraform state show "$ADDR" >/dev/null 2>&1; then
  echo "Key Vault Secrets Officer assignment already in Terraform state; skip import."
  exit 0
fi

if [ -z "$KV_NAME" ]; then
  KV_NAME=$(az keyvault list --resource-group "$RG" --query "[0].name" -o tsv 2>/dev/null || true)
fi
if [ -z "$KV_NAME" ]; then
  echo "No Key Vault in ${RG}; skip Secrets Officer import."
  exit 0
fi

# Deployer identity: pipeline sets ARM_CLIENT_ID (service principal app id).
# Prefer that so we import the SP assignment Terraform manages, not a human's.
if [ -n "${ARM_CLIENT_ID:-}" ]; then
  PRINCIPAL_ID=$(az ad sp show --id "$ARM_CLIENT_ID" --query id -o tsv)
elif [ -n "${servicePrincipalId:-}" ]; then
  PRINCIPAL_ID=$(az ad sp show --id "$servicePrincipalId" --query id -o tsv)
else
  PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv 2>/dev/null || true)
fi
if [ -z "$PRINCIPAL_ID" ]; then
  echo "Could not resolve deployer principal id; skip Secrets Officer import."
  exit 0
fi

KV_ID=$(az keyvault show --name "$KV_NAME" --resource-group "$RG" --query id -o tsv)
ASSIGN_ID=$(az role assignment list \
  --scope "$KV_ID" \
  --assignee "$PRINCIPAL_ID" \
  --role "$ROLE_NAME" \
  --query "[0].id" -o tsv 2>/dev/null || true)

if [ -z "$ASSIGN_ID" ]; then
  echo "No existing ${ROLE_NAME} assignment for deployer on ${KV_NAME}; skip import."
  exit 0
fi

echo "Importing existing Key Vault Secrets Officer assignment into state: ${ASSIGN_ID}"
terraform import -var-file=terraform.tfvars "$ADDR" "$ASSIGN_ID"
