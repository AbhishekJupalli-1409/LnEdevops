terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.0"
    }
  }
}

resource "azuredevops_project" "this" {
  name               = var.project_name
  description        = "Employee app (React + Node) and Todo List platform - infra, images, GitOps."
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

# --- Service connections -----------------------------------------------------

resource "azuredevops_serviceendpoint_azurerm" "subscription" {
  project_id            = azuredevops_project.this.id
  service_endpoint_name = "acr-service-connection-arm"
  credentials {
    serviceprincipalid  = var.sp_client_id
    serviceprincipalkey = var.sp_client_secret
  }
  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.subscription_id
  azurerm_subscription_name = var.subscription_name
}

resource "azuredevops_serviceendpoint_azurecr" "acr" {
  project_id             = azuredevops_project.this.id
  service_endpoint_name  = "acr-service-connection"
  resource_group         = var.acr_resource_group
  azurecr_name            = var.acr_name
  azurecr_spn_tenantid     = var.tenant_id
  azurecr_subscription_id  = var.subscription_id
  azurecr_subscription_name = var.subscription_name
}

resource "azuredevops_serviceendpoint_github" "github" {
  project_id            = azuredevops_project.this.id
  service_endpoint_name = "github-connection"
  auth_personal {
    personal_access_token = var.github_service_connection_pat
  }
}

# --- Shared variables used across pipelines ----------------------------------

resource "azuredevops_variable_group" "shared" {
  project_id   = azuredevops_project.this.id
  name         = "empapp-shared-vars"
  allow_access = true

  variable {
    name  = "acrLoginServer"
    value = "${var.acr_name}.azurecr.io"
  }
  variable {
    name  = "acrServiceConnection"
    value = azuredevops_serviceendpoint_azurecr.acr.service_endpoint_name
  }
  variable {
    name  = "armServiceConnection"
    value = azuredevops_serviceendpoint_azurerm.subscription.service_endpoint_name
  }
}

# --- Pipelines (build definitions) -------------------------------------------
# Each pipeline lives as YAML in its own repo (the 3 app repos already carry
# the dockerize pipelines added earlier; this platform repo carries the
# infra/helm/flux/aci pipelines). This module just registers each one with
# Azure DevOps and points it at the right repo + YAML path.

locals {
  app_pipelines = {
    "employee-frontend-ci" = { repo = "sample-react-app",  path = "azure-pipelines.yml" }
    "employee-backend-ci"  = { repo = "sample-node-app",   path = "azure-pipelines.yml" }
    "todolist-ci"           = { repo = "Todo-List-Dockerized-Flask-WebApp", path = "azure-pipelines.yml" }
  }
  platform_pipelines = {
    "infra-terraform"        = "pipelines/infra-terraform-azure-pipelines.yml"
    "ingress-nginx-helm"     = "pipelines/ingress-nginx-helm-azure-pipelines.yml"
    "aci-backend-deploy"     = "pipelines/aci-backend-deploy-azure-pipelines.yml"
    "flux-bootstrap"         = "pipelines/flux-bootstrap-azure-pipelines.yml"
  }
}

resource "azuredevops_build_definition" "app" {
  for_each   = local.app_pipelines
  project_id = azuredevops_project.this.id
  name       = each.key

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"
    repo_id                = "${var.github_org}/${each.value.repo}"
    branch_name             = "main"
    yml_path                = each.value.path
    service_connection_id   = azuredevops_serviceendpoint_github.github.id
  }
}

resource "azuredevops_build_definition" "platform" {
  for_each   = local.platform_pipelines
  project_id = azuredevops_project.this.id
  name       = each.key

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"
    repo_id                = "${var.github_org}/${var.platform_repo_name}"
    branch_name             = "main"
    yml_path                = each.value
    service_connection_id   = azuredevops_serviceendpoint_github.github.id
  }
}
