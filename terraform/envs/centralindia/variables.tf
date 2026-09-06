variable "subscription_id" { type = string }

variable "location" {
  type    = string
  default = "centralindia"
}

variable "resource_group_name" {
  type    = string
  default = "rg-empapp-centralindia"
}

variable "business_unit" {
  description = "Value for the mandatory 'Business Unit' tag. Any value is accepted by policy."
  type        = string
  default     = "EmployeeApps"
}

variable "cost_center" {
  description = "Value for the mandatory 'Cost Center' tag. Any value is accepted by policy."
  type        = string
  default     = "CC-0001"
}

variable "allowed_locations" {
  type    = list(string)
  default = ["centralindia", "southindia", "westindia"]
}

variable "backend_container_port" {
  type    = number
  default = 8000
}

variable "frontend_origin" {
  description = <<-EOT
    Scheme + host of the ingress-nginx public IP, e.g. "http://20.198.1.2"
    (no trailing slash, no path). The backend's CORS whitelist (WHITELIST_URLS)
    only accepts requests whose Origin header matches this exactly.
    This is only known AFTER step 3 (nginx ingress install) hands out a
    public IP, so the default below is a placeholder - update this variable
    and re-apply (or re-run the aci-backend-deploy pipeline) once you have
    the real IP. See docs/RUNBOOK.md.
  EOT
  type    = string
  default = "http://REPLACE-WITH-INGRESS-PUBLIC-IP"
}

variable "azdo_agent_pool_name" {
  description = "Agent pool the private VM registers into. Point the ingress-nginx-helm and flux-bootstrap pipelines at this pool (they must NOT run on Microsoft-hosted agents - the AKS API server is private)."
  type        = string
  default     = "empapp-private-pool"
}

variable "manage_azure_devops" {
  description = "Set true to also let Terraform manage the Azure DevOps project/pipelines/service connections (module.azuredevops). Requires the org to already exist and PAT variables to be set."
  type        = bool
  default     = false
}

variable "azdo_org_service_url" {
  type    = string
  default = ""
}
variable "azdo_personal_access_token" {
  type      = string
  default   = ""
  sensitive = true
}
variable "azdo_github_org" {
  type    = string
  default = ""
}
variable "azdo_github_service_connection_pat" {
  type      = string
  default   = ""
  sensitive = true
}
variable "azdo_sp_client_id" {
  type    = string
  default = ""
}
variable "azdo_sp_client_secret" {
  type      = string
  default   = ""
  sensitive = true
}
variable "azdo_tenant_id" {
  type    = string
  default = ""
}
variable "azdo_subscription_name" {
  type    = string
  default = ""
}
