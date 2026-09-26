terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  purge_protection_enabled      = false
  soft_delete_retention_days    = 7
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}

# The identity running this apply (the pipeline service principal) must be
# able to write secrets. Contributor does not include Key Vault data plane.
resource "azurerm_role_assignment" "current_secrets_officer" {
  scope                            = azurerm_key_vault.this.id
  role_definition_name             = "Key Vault Secrets Officer"
  principal_id                     = data.azurerm_client_config.current.object_id
  skip_service_principal_aad_check = true
}

resource "time_sleep" "kv_rbac" {
  depends_on      = [azurerm_role_assignment.current_secrets_officer]
  create_duration = "60s"
}

resource "azurerm_key_vault_secret" "this" {
  for_each     = nonsensitive(toset(keys(var.secrets)))
  name         = each.key
  value        = var.secrets[each.key]
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [time_sleep.kv_rbac]
}

resource "azurerm_private_endpoint" "vault" {
  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "vault"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "vault"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
