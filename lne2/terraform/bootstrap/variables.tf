variable "state_resource_group_name" {
  type    = string
  default = "rg-voteapp-tfstate-cin"
}

variable "location" {
  type    = string
  default = "centralindia"
}

variable "tags" {
  type = map(string)
  default = {
    "Department"    = "Engineering"
    "Project Code"  = "VOTEAPP"
    "Business Unit" = "Platform"
    "Cost Center"   = "CC-0001"
  }
}
