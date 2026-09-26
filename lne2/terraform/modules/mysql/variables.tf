variable "server_name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "administrator_login" { type = string }
variable "administrator_password" {
  type      = string
  sensitive = true
}
variable "database_name" {
  type    = string
  default = "voting"
}
variable "pe_subnet_id" { type = string }
variable "private_dns_zone_id" { type = string }
variable "tags" { type = map(string) }
