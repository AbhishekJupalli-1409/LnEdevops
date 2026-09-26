# User-assigned identity so the container group can pull from ACR via RBAC
# instead of a stored admin username/password (ACR admin user stays disabled).
resource "azurerm_user_assigned_identity" "aci" {
  name                = "${var.container_group_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "aci_acr_pull" {
  scope                             = var.acr_id
  role_definition_name              = "AcrPull"
  principal_id                      = azurerm_user_assigned_identity.aci.principal_id
  skip_service_principal_aad_check  = true
}

# ip_address_type = "Private" + subnet_ids injects the container group
# directly into snet-aci. It never gets a public IP; the only inbound path
# is from inside the VNet, and nsg-aci (networking module) further restricts
# that to just the AKS subnet on the backend port.
resource "azurerm_container_group" "backend" {
  name                = var.container_group_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  ip_address_type     = "Private"
  subnet_ids          = [var.aci_subnet_id]
  restart_policy      = "Always"
  tags                = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aci.id]
  }

  image_registry_credential {
    server                    = var.acr_login_server
    user_assigned_identity_id = azurerm_user_assigned_identity.aci.id
  }

  container {
    name   = "backend"
    image  = "${var.acr_login_server}/${var.image_repository}:${var.image_tag}"
    cpu    = var.cpu
    memory = var.memory

    ports {
      port     = var.container_port
      protocol = "TCP"
    }

    environment_variables         = var.environment_variables
    secure_environment_variables  = var.secure_environment_variables
  }

  depends_on = [azurerm_role_assignment.aci_acr_pull]
}
