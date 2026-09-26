variable "server_name"          { type = string }
variable "resource_group_name"  { type = string }
variable "location"             { type = string }
variable "tags"                 { type = map(string) }
variable "postgres_subnet_id"   { type = string }
variable "private_dns_zone_id"  { type = string }

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "administrator_login" {
  type    = string
  default = "pgadmin"
}

variable "storage_mb" {
  type    = number
  default = 32768
}

# Small compute (Burstable B-series) per the "B1*" guidance.
variable "sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "database_name" {
  description = "Database created for the Employee app."
  type        = string
  default     = "employeeappdb"
}
