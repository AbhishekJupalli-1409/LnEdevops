output "vnet_id" { value = azurerm_virtual_network.this.id }
output "vnet_name" { value = azurerm_virtual_network.this.name }
output "aks_subnet_id" { value = azurerm_subnet.aks.id }
output "pe_subnet_id" { value = azurerm_subnet.pe.id }
output "agent_subnet_id" { value = azurerm_subnet.agent.id }
output "mysql_private_dns_zone_id" { value = azurerm_private_dns_zone.mysql.id }
output "keyvault_private_dns_zone_id" { value = azurerm_private_dns_zone.keyvault.id }
