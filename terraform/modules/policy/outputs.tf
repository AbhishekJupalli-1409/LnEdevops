output "allowed_locations_assignment_id" {
  value = azurerm_subscription_policy_assignment.allowed_locations.id
}

output "require_tag_business_unit_assignment_id" {
  value = azurerm_subscription_policy_assignment.require_tag_business_unit.id
}

output "require_tag_cost_center_assignment_id" {
  value = azurerm_subscription_policy_assignment.require_tag_cost_center.id
}

output "no_public_ip_on_nic_assignment_id" {
  value = azurerm_subscription_policy_assignment.no_public_ip_on_nic.id
}
