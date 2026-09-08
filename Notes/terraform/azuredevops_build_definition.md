# azuredevops_build_definition

## Brief introduction

Defines an Azure Pipelines **build/pipeline** pointing at a YAML file in a repo.

## Why we create it

Register app + platform pipelines in AzDO as code (for_each over multiple YAML paths).

## How Terraform creates it

```hcl
resource "azuredevops_build_definition" "app" {
  for_each = var.app_pipelines
  project_id = azuredevops_project.this.id
  name       = each.key
  # yaml path under pipelines/
}

resource "azuredevops_build_definition" "platform" {
  for_each = var.platform_pipelines
  # infra, ingress, flux, aci restart, ...
}
```

## Use in this project

Creates definitions for the YAML under `pipelines/` (3 app + 4 platform style pipelines).

## Example to understand

Terraform tells AzDO: “Here is a pipeline named X that runs file Y whenever triggered.”
