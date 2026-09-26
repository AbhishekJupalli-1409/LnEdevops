output "vnet_id"   { value = azurerm_virtual_network.this.id }
output "vnet_name" { value = azurerm_virtual_network.this.name }

output "aks_subnet_id"      { value = azurerm_subnet.aks.id }
output "aci_subnet_id"      { value = azurerm_subnet.aci.id }
output "postgres_subnet_id" { value = azurerm_subnet.postgres.id }
output "pe_subnet_id"       { value = azurerm_subnet.pe.id }

output "postgres_private_dns_zone_id"   { value = azurerm_private_dns_zone.postgres.id }
output "postgres_private_dns_zone_name" { value = azurerm_private_dns_zone.postgres.name }
output "keyvault_private_dns_zone_id"   { value = azurerm_private_dns_zone.keyvault.id }

output "aci_nsg_name" { value = azurerm_network_security_group.aci.name }
output "agent_subnet_id" { value = azurerm_subnet.agent.id }
