variable "container_group_name" { type = string }
variable "resource_group_name"  { type = string }
variable "location"             { type = string }
variable "tags"                 { type = map(string) }
variable "aci_subnet_id"        { type = string }
variable "acr_id"               { type = string }
variable "acr_login_server"     { type = string }

variable "image_repository" {
  type    = string
  default = "employee-app-backend"
}
variable "image_tag" {
  type    = string
  default = "latest"
}

# Small compute per the "basic/small" guidance.
variable "cpu" {
  type    = number
  default = 1
}
variable "memory" {
  type    = number
  default = 1.5
}

variable "container_port" {
  description = "Must match APPLICATION_PORT passed in environment_variables (default 8000 - see README for why 80 from the Dockerfile's EXPOSE is not actually correct)."
  type        = number
  default     = 8000
}

variable "environment_variables" {
  description = "Non-secret container env vars (APPLICATION_HOST, APPLICATION_PORT, DBHOST, DBDIALECT, WHITELIST_URLS, ...)."
  type        = map(string)
  default     = {}
}

variable "secure_environment_variables" {
  description = "Secret container env vars (DBPASSWORD, ...). Never rendered in plan/apply output."
  type        = map(string)
  default     = {}
  sensitive   = true
}
