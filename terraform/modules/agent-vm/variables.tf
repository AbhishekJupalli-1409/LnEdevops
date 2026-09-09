variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "tags"                { type = map(string) }
variable "agent_subnet_id"     { type = string }

variable "vm_name" {
  type    = string
  default = "vm-empapp-agent"
}

# Smallest burstable size that still runs kubectl/helm/flux for learning/free tier.
variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "admin_username" {
  type    = string
  default = "azureagent"
}

variable "azp_url" {
  description = "https://dev.azure.com/your-org"
  type        = string
}
variable "azp_token" {
  description = "PAT with Agent Pools (read & manage) scope."
  type        = string
  sensitive   = true
}
variable "azp_pool" {
  description = "Agent pool name this VM registers itself into. Point the ingress-nginx-helm and flux-bootstrap pipelines at this pool."
  type        = string
  default     = "empapp-private-pool"
}
