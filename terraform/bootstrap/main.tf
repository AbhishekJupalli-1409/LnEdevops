# ==============================================================================
# BOOTSTRAP — run this once, manually, BEFORE anything else in this repo.
#
# Terraform can't store its own state in a storage account that doesn't exist
# yet, so this tiny config uses local state to create just the remote-state
# storage account. Everything after this point (terraform/envs/centralindia)
# uses that storage account as its backend.
#
# Run:
#   cd terraform/bootstrap
#   terraform init
#   terraform apply
#   terraform output   # copy these values into envs/centralindia/backend.tf
# ==============================================================================

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
  }
  # Intentionally local state — this is the one config in the repo that
  # cannot use the remote backend, because it is what creates it.
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "state" {
  name     = var.state_resource_group_name
  location = var.location

  tags = {
    "Business Unit" = var.business_unit_tag
    "Cost Center"   = var.cost_center_tag
    purpose         = "terraform-remote-state"
  }
}

resource "random_string" "sa_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

resource "azurerm_storage_account" "state" {
  name                            = "tfstateemp${random_string.sa_suffix.result}"
  resource_group_name             = azurerm_resource_group.state.name
  location                        = azurerm_resource_group.state.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
  }

  tags = azurerm_resource_group.state.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}
