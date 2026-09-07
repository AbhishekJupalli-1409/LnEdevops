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
# Placeholders keep terraform validate/plan working when
# manage_azure_devops is false and the PAT is not set.
provider "azuredevops" {
  org_service_url       = coalesce(var.azdo_org_service_url, "https://dev.azure.com/placeholder")
  personal_access_token = coalesce(var.azdo_personal_access_token, "placeholder")
}
