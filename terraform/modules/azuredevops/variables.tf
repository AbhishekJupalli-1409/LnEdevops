# Connects to an Azure DevOps ORGANIZATION that already exists.
# Terraform (the azuredevops provider) cannot create the organization itself
# - that is the one manual, one-time step called out in the README - but it
# creates everything inside it: the project, service connections, variable
# group and pipeline (build) definitions.

variable "org_service_url" {
  description = "e.g. https://dev.azure.com/your-org"
  type        = string
}
variable "personal_access_token" {
  description = "PAT with Project & Team, Service Connections and Build permissions. Pass via TF_VAR / pipeline secret, never commit it."
  type        = string
  sensitive   = true
}

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
