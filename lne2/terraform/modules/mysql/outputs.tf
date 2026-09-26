output "fqdn" { value = azurerm_mysql_flexible_server.this.fqdn }
output "name" { value = azurerm_mysql_flexible_server.this.name }
output "database_name" { value = azurerm_mysql_flexible_database.voting.name }
output "private_endpoint_id" { value = azurerm_private_endpoint.mysql.id }
