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
# manage_azure_devops is false. The Azure RM service connection is not used.
#
# When we are NOT managing AzDO resources, leave personal_access_token unset
# so the provider uses AZDO_PERSONAL_ACCESS_TOKEN (pipeline System.AccessToken).
# The agent-VM PAT is often Agent-Pools-only (or a different identity) and
# 401s here with "You are not authorized to access Azure DevOps Organization".
provider "azuredevops" {
  org_service_url       = var.azdo_org_service_url
  personal_access_token = var.manage_azure_devops ? var.azdo_personal_access_token : null
}
