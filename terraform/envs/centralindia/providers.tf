terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}

# Configured at the root so module.azuredevops can use count.
# Terraform initializes this provider on every plan/apply, even when
# manage_azure_devops is false. It talks to Azure DevOps with a PAT (or
# AZDO_PERSONAL_ACCESS_TOKEN / the pipeline OAuth token) — the Azure RM
# service connection is not used here.
# An empty PAT in terraform.tfvars is left unset so the env var can be used.
provider "azuredevops" {
  org_service_url       = var.azdo_org_service_url
  personal_access_token = var.azdo_personal_access_token == "" ? null : var.azdo_personal_access_token
}
