# azuredevops_variable_group

## Brief introduction

Named set of pipeline variables (and secrets) shared across multiple pipelines — e.g. `empapp-shared-vars`.

## Why we create it

Avoid duplicating ACR name, state storage names, tokens across seven YAML pipelines.

## How Terraform creates it

```hcl
resource "azuredevops_variable_group" "shared" {
  project_id   = azuredevops_project.this.id
  name         = "empapp-shared-vars"
  allow_access = true
  variable { name = "acrName" value = var.acr_name }
  # secrets: azdoPersonalAccessToken, etc.
}
```

## Use in this project

Referenced as `- group: empapp-shared-vars` in pipeline YAML.

## Example to understand

A shared sticky-note board of settings every pipeline can read.
