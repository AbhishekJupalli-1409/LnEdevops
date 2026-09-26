resource "random_password" "administrator" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]"
}

# Private access (VNet integration) via a delegated subnet - see the note in
# modules/networking/main.tf on why this is used instead of the separate
# Private Endpoint feature. Must set public_network_access_enabled = false
# explicitly: the provider defaults it to true, which Azure rejects when a
# delegated subnet is set (ConflictingPublicNetworkAccessAndVirtualNetworkConfiguration).
resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.postgres_version

  delegated_subnet_id           = var.postgres_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false

  administrator_login    = var.administrator_login
  administrator_password = random_password.administrator.result

  storage_mb                   = var.storage_mb
  sku_name                     = var.sku_name
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = false

  tags = var.tags

  lifecycle {
    ignore_changes = [zone]
  }
}

# Database used by the Employee app (frontend + backend).
resource "azurerm_postgresql_flexible_server_database" "employee" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}
