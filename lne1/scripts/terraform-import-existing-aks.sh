#!/usr/bin/env bash
# Adopt an AKS cluster that Azure created on a failed apply but Terraform
# never recorded in state. Safe to re-run: no-op if the cluster is already
# in state or does not exist (fresh subscription).
set -euo pipefail

RG="${RESOURCE_GROUP_NAME:-rg-empapp-centralindia}"
NAME="${AKS_CLUSTER_NAME:-aks-empapp-cin}"
ADDR="module.aks.azurerm_kubernetes_cluster.this"

if terraform state show "$ADDR" >/dev/null 2>&1; then
  echo "AKS already in Terraform state; skip import."
  exit 0
fi

if ! az aks show --resource-group "$RG" --name "$NAME" >/dev/null 2>&1; then
  echo "No existing AKS cluster ${NAME} in ${RG}; skip import."
  exit 0
fi

SUB=$(az account show --query id -o tsv)
ID="/subscriptions/${SUB}/resourceGroups/${RG}/providers/Microsoft.ContainerService/managedClusters/${NAME}"
echo "Importing existing AKS cluster into state: ${ID}"
terraform import -var-file=terraform.tfvars "$ADDR" "$ID"
