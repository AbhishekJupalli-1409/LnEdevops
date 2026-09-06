# ==============================================================================
# Subscription-scope Azure Policy assignments.
# All three use built-in policy definitions (verified GUIDs) so no custom
# policy JSON has to be authored or maintained.
# ==============================================================================

data "azurerm_subscription" "current" {}

# --- 1. Allowed locations ----------------------------------------------------
# Built-in "Allowed locations" (e56962a6-4747-49cd-b67b-bf8b01975c4c)
resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations-india"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  display_name         = "Allowed locations - India region"
  description          = "Resources may only be deployed to Central India, South India or West India."

  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

# --- 2. Mandatory tags --------------------------------------------------------
# Built-in "Require a tag on resources" (871b6d14-10aa-478d-b590-94f262ecfa99)
# is parameterised by a single tag name, so it is assigned twice — once per
# required tag — rather than written as a custom policy.
resource "azurerm_subscription_policy_assignment" "require_tag_business_unit" {
  name                 = "require-tag-business-unit"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  display_name         = "Require 'Business Unit' tag"
  description          = "Denies creation of any resource that does not carry a 'Business Unit' tag."

  parameters = jsonencode({
    tagName = { value = "Business Unit" }
  })
}

resource "azurerm_subscription_policy_assignment" "require_tag_cost_center" {
  name                 = "require-tag-cost-center"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  display_name         = "Require 'Cost Center' tag"
  description          = "Denies creation of any resource that does not carry a 'Cost Center' tag."

  parameters = jsonencode({
    tagName = { value = "Cost Center" }
  })
}

# --- 3. No public IPs on NICs -------------------------------------------------
# Built-in "Network interfaces should not have public IPs"
# (83a86a26-fd1f-447c-b59d-e51f44264114). Fixed Deny effect, no parameters.
resource "azurerm_subscription_policy_assignment" "no_public_ip_on_nic" {
  name                 = "deny-nic-public-ip"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"
  display_name         = "Deny public IPs on network interfaces"
  description          = "Denies any network interface configured with a public IP address."
}
