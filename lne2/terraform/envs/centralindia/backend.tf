# The infra pipeline passes these at init. They are the bootstrap outputs
# for subscription lne.azure5 (0b6312f9-7bd8-4826-85aa-c805a64c18d4):
#   resource_group_name  = rg-voteapp-tfstate-cin
#   storage_account_name = tfstatevote3gwpva
#   container_name       = tfstate
#   key                  = voteapp.terraform.tfstate
terraform {
  backend "azurerm" {}
}
