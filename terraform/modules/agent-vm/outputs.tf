output "vm_id"              { value = azurerm_linux_virtual_machine.agent.id }
output "vm_name"            { value = azurerm_linux_virtual_machine.agent.name }
output "private_ip_address" { value = azurerm_network_interface.agent.private_ip_address }
output "ssh_private_key_pem" {
  value     = tls_private_key.agent.private_key_pem
  sensitive = true
}
