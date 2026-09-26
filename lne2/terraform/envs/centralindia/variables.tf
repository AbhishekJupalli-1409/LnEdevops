variable "subscription_id" { type = string }
variable "tenant_id" { type = string }

variable "location" {
  type    = string
  default = "centralindia"
}

variable "resource_group_name" {
  type    = string
  default = "rg-voteapp-centralindia"
}

variable "vnet_name" {
  type    = string
  default = "vnet-voteapp-cin"
}

variable "vnet_address_space" {
  type    = string
  default = "10.20.0.0/16"
}

variable "aks_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "pe_subnet_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

variable "agent_subnet_cidr" {
  type    = string
  default = "10.20.4.0/24"
}

variable "pod_cidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "service_cidr" {
  type    = string
  default = "10.21.0.0/16"
}

variable "dns_service_ip" {
  type    = string
  default = "10.21.0.10"
}

variable "aks_cluster_name" {
  type    = string
  default = "aks-voteapp-cin"
}

variable "aks_node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "aks_node_count" {
  type    = number
  default = 1
}

variable "mysql_admin_login" {
  type    = string
  default = "voteadmin"
}

variable "mysql_database_name" {
  type    = string
  default = "voting"
}

variable "key_vault_public_network_access_enabled" {
  description = "Leave true for the first apply so the hosted pipeline can write secrets. The private endpoint still exists for in-VNet clients."
  type        = bool
  default     = true
}

variable "enable_policy_assignments" {
  type    = bool
  default = true
}

variable "allowed_locations" {
  type    = list(string)
  default = ["centralindia", "southindia", "westindia"]
}

variable "department" {
  type    = string
  default = "Engineering"
}

variable "project_code" {
  type    = string
  default = "VOTEAPP"
}

variable "azdo_org_service_url" {
  type    = string
  default = "https://dev.azure.com/jupalliabhishek1409"
}

variable "azdo_agent_pool" {
  type    = string
  default = "voteapp-private-pool"
}

variable "azdo_personal_access_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "agent_vm_size" {
  type    = string
  default = "Standard_B2s_v2"
}

variable "agent_admin_username" {
  type    = string
  default = "azureagent"
}
