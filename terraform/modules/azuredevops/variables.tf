# Connects to an Azure DevOps ORGANIZATION that already exists.
# Terraform (the azuredevops provider) cannot create the organization itself
# - that is the one manual, one-time step called out in the README - but it
# creates everything inside it: the project, service connections, variable
# group and pipeline (build) definitions.
#
# The azuredevops provider is configured by the caller, not this module.
# Nested provider blocks would make this a legacy module and forbid count.

variable "project_name" {
  type    = string
  default = "employee-app-platform"
}

variable "subscription_id"   { type = string }
variable "subscription_name" { type = string }
variable "tenant_id"         { type = string }

variable "sp_client_id" {
  description = "App registration (service principal) used for the ARM service connection."
  type        = string
}
variable "sp_client_secret" {
  type      = string
  sensitive = true
}

variable "acr_name"             { type = string }
variable "acr_resource_group"   { type = string }

variable "github_org" {
  description = "GitHub org/user that owns the four repos this platform touches."
  type        = string
}
variable "github_service_connection_pat" {
  description = "GitHub PAT (repo scope) so Azure DevOps can check out the app repos and this platform repo."
  type        = string
  sensitive   = true
}
variable "platform_repo_name" {
  description = "Name of the repo this generated project itself is pushed to."
  type        = string
  default     = "employee-app-platform"
}
