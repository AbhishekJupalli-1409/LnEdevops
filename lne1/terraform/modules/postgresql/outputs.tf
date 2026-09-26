output "server_id"   { value = azurerm_postgresql_flexible_server.this.id }
output "server_fqdn" { value = azurerm_postgresql_flexible_server.this.fqdn }
output "database_name" { value = azurerm_postgresql_flexible_server_database.employee.name }
output "administrator_login" { value = var.administrator_login }
output "administrator_password" {
  value     = random_password.administrator.result
  sensitive = true
}
