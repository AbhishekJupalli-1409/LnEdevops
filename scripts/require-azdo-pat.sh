#!/usr/bin/env bash
# Sourced by pipelines/infra-terraform-azure-pipelines.yml.
# Expects AZDO_PAT (mapped from secret azdoPersonalAccessToken) and optional
# SYSTEM_ACCESSTOKEN. Exports TF_VAR_azdo_personal_access_token for the
# agent VM and AZDO_PERSONAL_ACCESS_TOKEN for the unused azuredevops provider.
set -euo pipefail

if [ -z "${AZDO_PAT:-}" ] || [ "${AZDO_PAT}" = '$(azdoPersonalAccessToken)' ]; then
  echo "##vso[task.logissue type=error]Secret azdoPersonalAccessToken did not resolve to a PAT. In Azure DevOps: Pipelines > Library > empapp-shared-vars > add secret named exactly azdoPersonalAccessToken (PAT created in this org, Agent Pools: Read & manage). Open the pipeline and permit the variable group if prompted."
  exit 1
fi

export AZDO_PERSONAL_ACCESS_TOKEN="${SYSTEM_ACCESSTOKEN:-$AZDO_PAT}"
export TF_VAR_azdo_personal_access_token="$AZDO_PAT"
