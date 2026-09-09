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

# Smallest AKS *system* pool SKU that Azure actually accepts. B-series
# (burstable) VMs are NOT allowed for system node pools - they fail with
# SystemPoolSkuTooLow - so this must stay on a D-series. Standard_D2s_v3
# (2 vCPU / 8 GB) is the cheapest reliable, widely-available valid size in
# centralindia. Pair with node_count = 1 to keep the cost minimal.
# Do not set this to Standard_B2s / B2s_v2 — that SKU is only for the agent VM.
variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
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
