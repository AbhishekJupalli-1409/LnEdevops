# azuredevops_project

## Brief introduction

An Azure DevOps **project** holds repos (or GitHub links), pipelines, boards, and service connections.

## Why we create it

Optionally provision the AzDO project and wiring via Terraform so CI/CD is reproducible (module is count-gated).

## How Terraform creates it

```hcl
resource "azuredevops_project" "this" {
  name               = var.project_name
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}
```

Module: `terraform/modules/azuredevops` (optional).

## Use in this project

Home for pipelines and the shared variable group / service endpoints.

## Example to understand

Creating the “Employee App” project space in Azure DevOps automatically instead of clicking through the UI.
