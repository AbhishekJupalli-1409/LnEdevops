variable "cluster_name"        { type = string }
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "tags"                { type = map(string) }
variable "aks_subnet_id"       { type = string }
variable "acr_id"              { type = string }

variable "dns_prefix" {
  type    = string
  default = "empapp-aks"
}

# Cheapest commonly-available AKS node size for free/learning subscriptions.
# Upgrade to Standard_D2s_v3 if the region rejects B-series for AKS.
variable "node_vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "kubernetes_version" {
  description = "Leave null to let Azure pick its current default supported version."
  type        = string
  default     = null
}

variable "pod_cidr" {
  description = "Only used because network_plugin = kubenet. Must not overlap the VNet."
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "dns_service_ip" {
  type    = string
  default = "10.20.0.10"
}
