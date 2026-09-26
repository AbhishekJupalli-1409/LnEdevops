# Filled in from `terraform output` in terraform/bootstrap. Values below are
# placeholders on purpose - either edit them directly, or (recommended, so
# nothing environment-specific is hardcoded in git) leave this block with
# just `backend "azurerm" {}` and pass the four values at init time:
#
#   terraform init \
#     -backend-config="resource_group_name=<from bootstrap output>" \
#     -backend-config="storage_account_name=<from bootstrap output>" \
#     -backend-config="container_name=tfstate" \
#     -backend-config="key=centralindia.terraform.tfstate"
#
# The Azure DevOps infra-terraform pipeline does exactly this using pipeline
# variables - see pipelines/infra-terraform-azure-pipelines.yml.

terraform {
  backend "azurerm" {
    # resource_group_name  = ""
    # storage_account_name = ""
    # container_name       = "tfstate"
    # key                  = "centralindia.terraform.tfstate"
  }
}
