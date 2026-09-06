variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "tags"                { type = map(string) }
variable "agent_subnet_id"     { type = string }

variable "vm_name" {
  type    = string
  default = "vm-empapp-agent"
}

# Small compute; a bit more than B1s so it can comfortably run kubectl/helm/
# flux CLI operations (B1s' 1GB RAM is workable but tight for that).
variable "vm_size" {
  type    = string
  default = "Standard_B2s"
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
