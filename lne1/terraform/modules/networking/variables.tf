variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "tags"                { type = map(string) }

variable "vnet_name" {
  type    = string
  default = "vnet-empapp-cin"
}

variable "vnet_address_space" {
  type    = string
  default = "10.10.0.0/16"
}

variable "aks_subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "aci_subnet_cidr" {
  type    = string
  default = "10.10.2.0/24"
}

variable "postgres_subnet_cidr" {
  type    = string
  default = "10.10.3.0/24"
}

variable "pe_subnet_cidr" {
  type    = string
  default = "10.10.4.0/24"
}

variable "agent_subnet_cidr" {
  description = "Subnet for the private self-hosted DevOps build agent VM (needs direct VNet access to the private AKS API server)."
  type        = string
  default     = "10.10.5.0/24"
}

variable "backend_port" {
  description = "TCP port the backend (ACI) container listens on. Only the AKS subnet is allowed to reach it."
  type        = string
  default     = "8000"
}
