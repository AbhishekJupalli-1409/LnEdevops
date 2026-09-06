variable "state_resource_group_name" {
  description = "Resource group that holds the Terraform remote-state storage account."
  type        = string
  default     = "rg-empapp-tfstate-cin"
}

variable "location" {
  description = "Azure region for the state resource group. Kept in Central India like everything else."
  type        = string
  default     = "centralindia"
}

variable "business_unit_tag" {
  type    = string
  default = "Platform"
}

variable "cost_center_tag" {
  type    = string
  default = "CC-0001"
}
