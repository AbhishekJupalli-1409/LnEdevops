# azuredevops_serviceendpoint_azurecr

## Brief introduction

Service connection for pushing/pulling images to Azure Container Registry from pipelines.

## Why we create it

App build pipelines need to `docker push` to ACR.

## How Terraform creates it

```hcl
resource "azuredevops_serviceendpoint_azurecr" "acr" {
  project_id                = azuredevops_project.this.id
  service_endpoint_name     = "empapp-acr"
  azurecr_name              = var.acr_name
  # subscription / RG details
}
```

## Use in this project

Frontend, backend, and todolist image publish steps.

## Example to understand

Pipeline’s badge to open the image warehouse and upload new builds.
