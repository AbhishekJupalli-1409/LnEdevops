output "private_ip" { value = azurerm_network_interface.agent.private_ip_address }
output "principal_id" { value = azurerm_linux_virtual_machine.agent.identity[0].principal_id }
output "name" { value = azurerm_linux_virtual_machine.agent.name }
output "ssh_private_key_pem" {
  value     = tls_private_key.agent.private_key_pem
  sensitive = true
}
