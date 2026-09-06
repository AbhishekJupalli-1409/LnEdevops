data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = var.tags

  enable_rbac_authorization      = true
  purge_protection_enabled       = false
  soft_delete_retention_days     = 7
  public_network_access_enabled  = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_private_endpoint" "keyvault" {
  name                = "${var.key_vault_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.key_vault_name}-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}

# The identity running `terraform apply` (a human or the pipeline's service
# principal) needs Secrets Officer to be able to write the secrets below.
resource "azurerm_role_assignment" "deployer_secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  value        = var.postgres_admin_password
  key_vault_id = azurerm_key_vault.this.id
  depends_on   = [azurerm_role_assignment.deployer_secrets_officer]
}

resource "azurerm_key_vault_secret" "postgres_connection_string" {
  name         = "postgres-connection-string"
  value        = var.postgres_connection_string
  key_vault_id = azurerm_key_vault.this.id
  depends_on   = [azurerm_role_assignment.deployer_secrets_officer]
}

resource "azurerm_key_vault_secret" "extra" {
  for_each     = var.extra_secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id
  depends_on   = [azurerm_role_assignment.deployer_secrets_officer]
}
