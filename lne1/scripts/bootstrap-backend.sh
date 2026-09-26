#!/usr/bin/env bash
# One-time, run manually before anything else. Creates the storage account
# that holds Terraform's remote state (terraform/bootstrap uses local state
# to do this, since nothing can store its own backend before it exists).
set -euo pipefail

cd "$(dirname "$0")/../terraform/bootstrap"

az login --only-show-errors >/dev/null || true

terraform init
terraform apply -auto-approve

echo
echo "=== Copy these into terraform/envs/centralindia, or pass as -backend-config flags (see backend.tf) ==="
terraform output backend_config_snippet
