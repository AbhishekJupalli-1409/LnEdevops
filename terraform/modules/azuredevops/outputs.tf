output "project_id"   { value = azuredevops_project.this.id }
output "project_name" { value = azuredevops_project.this.name }
output "arm_service_connection_name" { value = azuredevops_serviceendpoint_azurerm.subscription.service_endpoint_name }
output "acr_service_connection_name" { value = azuredevops_serviceendpoint_azurecr.acr.service_endpoint_name }
