# Basic SKU does not support a private endpoint. Image push and pull use
# Azure AD (AcrPush on the pipeline identity, AcrPull on the kubelet).
# Admin user stays off.
resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}
