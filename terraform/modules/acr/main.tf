# Basic SKU per the "use basic SKUs / small compute" requirement.
#
# Trade-off this implies: Basic (and Standard) ACR does NOT support Private
# Link / Private Endpoint - only Premium does. The task's private-endpoint
# requirement is explicitly scoped to frontend<->backend and
# backend<->postgres, not to image pulls, so this is a deliberate choice,
# not an oversight. Pulls are still locked down with Azure AD RBAC
# (AcrPull role, granted to AKS's kubelet identity and to the ACI backend's
# managed identity in their respective modules) - the admin user stays
# disabled so there is no shared/static credential at all.
resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}
