resource "azurerm_mysql_flexible_server" "this" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  administrator_login          = var.administrator_login
  administrator_password       = var.administrator_password
  sku_name                     = "B_Standard_B1ms"
  version                      = "8.0.21"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  zone                         = "1"
  tags                         = var.tags

  # azurerm 3.117 decides public_network_access_enabled itself. Leaving
  # delegated_subnet_id unset keeps the server in public-access mode, but
  # this module creates no firewall rule, so the internet cannot log in.
  # AKS reaches the server only through the private endpoint below.
  storage {
    size_gb = 20
  }

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_mysql_flexible_database" "voting" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

resource "azurerm_private_endpoint" "mysql" {
  name                = "pe-${var.server_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "mysql"
    private_connection_resource_id = azurerm_mysql_flexible_server.this.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "mysql"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
