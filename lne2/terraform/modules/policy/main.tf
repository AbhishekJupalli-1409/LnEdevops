data "azurerm_subscription" "current" {}

resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "voteapp-allowed-locations-india"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  display_name         = "Vote app - allowed locations India"
  description          = "Resources may only be deployed to Central India, South India, or West India."

  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

resource "azurerm_subscription_policy_assignment" "require_department" {
  name                 = "voteapp-require-tag-department"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  display_name         = "Vote app - require Department tag"
  description          = "Denies a resource that does not carry the Department tag."
  not_scopes           = var.excluded_scopes

  parameters = jsonencode({
    tagName = { value = var.department_tag_name }
  })
}

resource "azurerm_subscription_policy_assignment" "require_project_code" {
  name                 = "voteapp-require-tag-project-code"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  display_name         = "Vote app - require Project Code tag"
  description          = "Denies a resource that does not carry the Project Code tag."
  not_scopes           = var.excluded_scopes

  parameters = jsonencode({
    tagName = { value = var.project_code_tag_name }
  })
}

resource "azurerm_subscription_policy_assignment" "no_public_ip_on_nic" {
  name                 = "voteapp-deny-nic-public-ip"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"
  display_name         = "Vote app - deny public IPs on network interfaces"
  description          = "Denies a network interface configured with a public IP address."
}
