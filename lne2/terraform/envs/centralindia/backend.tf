# Leave the four settings empty in git. The infra pipeline passes them at init:
#   terraform init \
#     -backend-config="resource_group_name=$(tfStateResourceGroup)" \
#     -backend-config="storage_account_name=$(tfStateStorageAccount)" \
#     -backend-config="container_name=$(tfStateContainer)" \
#     -backend-config="key=voteapp.terraform.tfstate"
terraform {
  backend "azurerm" {}
}
