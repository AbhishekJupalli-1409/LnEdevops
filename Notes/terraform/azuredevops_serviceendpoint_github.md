# azuredevops_serviceendpoint_github

## Brief introduction

Connects Azure Pipelines to GitHub (often via PAT) to checkout app repos or for Flux-related GitHub access patterns.

## Why we create it

App pipelines may live against GitHub repos (sample apps); PAT-backed connection authenticates clones.

## How Terraform creates it

```hcl
resource "azuredevops_serviceendpoint_github" "github" {
  project_id            = azuredevops_project.this.id
  service_endpoint_name = "empapp-github"
  auth_personal {
    personal_access_token = var.github_pat
  }
}
```

## Use in this project

GitHub integration for pipeline source / related automation.

## Example to understand

Stored GitHub credentials so AzDO can read repositories without interactive login.
