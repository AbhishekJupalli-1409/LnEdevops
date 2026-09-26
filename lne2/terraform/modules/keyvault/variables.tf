variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "tenant_id" { type = string }
variable "pe_subnet_id" { type = string }
variable "private_dns_zone_id" { type = string }
variable "public_network_access_enabled" {
  type    = bool
  default = true
}
variable "secrets" {
  type      = map(string)
  sensitive = true
  default   = {}
}
variable "tags" { type = map(string) }
