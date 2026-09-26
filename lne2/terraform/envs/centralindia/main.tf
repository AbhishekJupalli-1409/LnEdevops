locals {
  tags = {
    "Department"   = var.department
    "Project Code" = var.project_code
  }

  aks_node_resource_group_id = "/subscriptions/${var.subscription_id}/resourceGroups/MC_${var.resource_group_name}_${var.aks_cluster_name}_${var.location}"
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "random_string" "suffix" {
  length  = 5
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "random_password" "mysql" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

module "policy" {
  count             = var.enable_policy_assignments ? 1 : 0
  source            = "../../modules/policy"
  allowed_locations = var.allowed_locations
  excluded_scopes   = [local.aks_node_resource_group_id]
}

module "network" {
  source              = "../../modules/networking"
  vnet_name           = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  vnet_address_space  = var.vnet_address_space
  aks_subnet_cidr     = var.aks_subnet_cidr
  pe_subnet_cidr      = var.pe_subnet_cidr
  agent_subnet_cidr   = var.agent_subnet_cidr
  tags                = local.tags
}

module "acr" {
  source              = "../../modules/acr"
  acr_name            = "acrvoteapp${random_string.suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

module "aks" {
  source              = "../../modules/aks"
  cluster_name        = var.aks_cluster_name
  dns_prefix          = "aksvoteapp"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  aks_subnet_id       = module.network.aks_subnet_id
  acr_id              = module.acr.id
  node_vm_size        = var.aks_node_vm_size
  node_count          = var.aks_node_count
  pod_cidr            = var.pod_cidr
  service_cidr        = var.service_cidr
  dns_service_ip      = var.dns_service_ip
  tags                = local.tags
}

module "mysql" {
  source                 = "../../modules/mysql"
  server_name            = "mysql-voteapp-${random_string.suffix.result}"
  location               = var.location
  resource_group_name    = azurerm_resource_group.this.name
  administrator_login    = var.mysql_admin_login
  administrator_password = random_password.mysql.result
  database_name          = var.mysql_database_name
  pe_subnet_id           = module.network.pe_subnet_id
  private_dns_zone_id    = module.network.mysql_private_dns_zone_id
  tags                   = local.tags
}

module "keyvault" {
  source                        = "../../modules/keyvault"
  name                          = "kv-voteapp-${random_string.suffix.result}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  tenant_id                     = var.tenant_id
  pe_subnet_id                  = module.network.pe_subnet_id
  private_dns_zone_id           = module.network.keyvault_private_dns_zone_id
  public_network_access_enabled = var.key_vault_public_network_access_enabled
  tags                          = local.tags
  secrets = {
    mysql-admin-password     = random_password.mysql.result
    mysql-admin-user         = var.mysql_admin_login
    mysql-database-name      = var.mysql_database_name
    mysql-fqdn               = module.mysql.fqdn
    agent-vm-ssh-private-key = module.agent.ssh_private_key_pem
  }
}

module "agent" {
  source              = "../../modules/agent-vm"
  vm_name             = "vm-voteapp-agent"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  agent_subnet_id     = module.network.agent_subnet_id
  vm_size             = var.agent_vm_size
  admin_username      = var.agent_admin_username
  azp_url             = var.azdo_org_service_url
  azp_pool            = var.azdo_agent_pool
  azp_token           = var.azdo_personal_access_token
  tags                = local.tags
}

resource "azurerm_role_assignment" "agent_keyvault_reader" {
  scope                            = module.keyvault.id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = module.agent.principal_id
  skip_service_principal_aad_check = true
}
