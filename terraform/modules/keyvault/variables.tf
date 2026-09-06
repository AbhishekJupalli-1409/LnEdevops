variable "key_vault_name"       { type = string }
variable "resource_group_name"  { type = string }
variable "location"             { type = string }
variable "tags"                 { type = map(string) }
variable "pe_subnet_id"         { type = string }
variable "private_dns_zone_id"  { type = string }

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}
variable "postgres_connection_string" {
  type      = string
  sensitive = true
}

variable "extra_secrets" {
  description = "Any additional name/value secrets to store, e.g. future app secrets."
  type        = map(string)
  default     = {}
  sensitive   = true
}
