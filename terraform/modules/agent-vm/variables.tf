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
  default = "Standard_B2s_v2"
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

  validation {
    condition     = length(trimspace(var.azp_token)) > 0
    error_message = "azp_token is empty. Set TF_VAR_azdo_personal_access_token or pipeline secret azdoPersonalAccessToken. Do not assign azdo_personal_access_token = \"\" in terraform.tfvars — that overrides TF_VAR_*."
  }
}
variable "azp_pool" {
  description = "Agent pool name this VM registers itself into. Point the ingress-nginx-helm and flux-bootstrap pipelines at this pool."
  type        = string
  default     = "empapp-private-pool"
}
