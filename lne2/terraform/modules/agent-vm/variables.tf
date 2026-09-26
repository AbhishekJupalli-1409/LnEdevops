variable "vm_name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "agent_subnet_id" { type = string }
variable "vm_size" {
  type    = string
  default = "Standard_B2s_v2"
}
variable "admin_username" {
  type    = string
  default = "azureagent"
}
variable "azp_url" { type = string }
variable "azp_pool" { type = string }
variable "azp_token" {
  type      = string
  sensitive = true
}
variable "tags" { type = map(string) }
