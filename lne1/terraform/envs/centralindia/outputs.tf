output "resource_group_name" { value = azurerm_resource_group.this.name }
output "location"            { value = azurerm_resource_group.this.location }

output "acr_login_server" { value = module.acr.login_server }
output "acr_name"         { value = module.acr.name }

output "aks_cluster_name"        { value = module.aks.cluster_name }
output "aks_node_resource_group" { value = module.aks.node_resource_group }
output "aks_private_fqdn"        { value = module.aks.private_fqdn }

output "postgres_server_fqdn" { value = module.postgresql.server_fqdn }
output "postgres_database"   { value = module.postgresql.database_name }

output "key_vault_name" { value = module.keyvault.name }
output "key_vault_uri"  { value = module.keyvault.uri }

output "aci_backend_private_ip" { value = module.aci_backend.private_ip_address }

output "agent_vm_name"       { value = module.agent_vm.vm_name }
output "agent_vm_private_ip" { value = module.agent_vm.private_ip_address }

output "vnet_id"            { value = module.networking.vnet_id }
output "aks_subnet_id"      { value = module.networking.aks_subnet_id }
output "aci_subnet_id"      { value = module.networking.aci_subnet_id }
output "postgres_subnet_id" { value = module.networking.postgres_subnet_id }

output "kube_config_raw" {
  value     = module.aks.kube_config_raw
  sensitive = true
}

output "next_steps" {
  value = <<-EOT
    1. Confirm agent "${module.agent_vm.vm_name}" shows Online in Azure DevOps
       > Project Settings > Agent pools > ${var.azdo_agent_pool_name}
       (it self-registered via run-command during apply - give it ~3-5 min)
    2. Run pipelines/ingress-nginx-helm-azure-pipelines.yml (pool: ${var.azdo_agent_pool_name}), then:
       kubectl get svc -n ingress-nginx ingress-nginx-controller
       -> note the EXTERNAL-IP, that is your public ingress URL
    3. Update terraform.tfvars: frontend_origin = "http://<that EXTERNAL-IP>"
       and re-apply (refreshes the backend's CORS whitelist on ACI)
    4. Run pipelines/flux-bootstrap-azure-pipelines.yml to deploy frontend +
       todolist via GitOps
    5. See docs/RUNBOOK.md for the full, ordered walkthrough and
       docs/CREDENTIALS_TEMPLATE.md for where every generated secret lands
  EOT
}
