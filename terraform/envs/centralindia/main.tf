locals {
  tags = {
    "Business Unit" = var.business_unit
    "Cost Center"   = var.cost_center
  }
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

# Shared suffix so ACR / Key Vault / Postgres (all globally-unique names)
# don't collide with anyone else's deployment of this same project.
resource "random_string" "suffix" {
  length  = 5
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# --- 1. Subscription-scope guardrails -----------------------------------
# Skipped by default (enable_policy_assignments=false) so free/learning
# service principals without Resource Policy Contributor can still apply.
module "policy" {
  count             = var.enable_policy_assignments ? 1 : 0
  source            = "../../modules/policy"
  allowed_locations = var.allowed_locations
}

# --- 2. Networking ---------------------------------------------------------
module "networking" {
  source               = "../../modules/networking"
  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  tags                 = local.tags
  backend_port         = tostring(var.backend_container_port)
}

# --- 3. Container registry --------------------------------------------------
module "acr" {
  source               = "../../modules/acr"
  acr_name             = "acrempapp${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  tags                 = local.tags
}

# --- 4. AKS (private cluster) ------------------------------------------------
module "aks" {
  source               = "../../modules/aks"
  cluster_name         = "aks-empapp-cin"
  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  tags                 = local.tags
  aks_subnet_id        = module.networking.aks_subnet_id
  acr_id               = module.acr.id
}

# --- 5. PostgreSQL flexible server + employee DB -----------------------------
module "postgresql" {
  source               = "../../modules/postgresql"
  server_name          = "psql-empapp-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  tags                 = local.tags
  postgres_subnet_id   = module.networking.postgres_subnet_id
  private_dns_zone_id  = module.networking.postgres_private_dns_zone_id

  depends_on = [module.networking]
}

# --- 6. Private self-hosted DevOps agent VM ----------------------------------
# Needed because the AKS API server is private: a Microsoft-hosted pipeline
# agent runs on public Azure infra and simply cannot route to it. This VM
# sits inside the same VNet and is the one pipelines target for any
# kubectl/helm/flux step (ingress install, Flux bootstrap). No public IP on
# its NIC - outbound only, via the NAT gateway in the networking module.
module "agent_vm" {
  source              = "../../modules/agent-vm"
  resource_group_name = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  tags                 = local.tags
  agent_subnet_id      = module.networking.agent_subnet_id
  azp_url              = var.azdo_org_service_url
  azp_token            = var.azdo_personal_access_token
  azp_pool             = var.azdo_agent_pool_name

  depends_on = [module.networking]
}

# --- 7. Key Vault -------------------------------------------------------------
module "keyvault" {
  source                        = "../../modules/keyvault"
  key_vault_name                = "kv-empapp-${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  tags                          = local.tags
  pe_subnet_id                  = module.networking.pe_subnet_id
  private_dns_zone_id           = module.networking.keyvault_private_dns_zone_id
  postgres_admin_password       = module.postgresql.administrator_password
  postgres_connection_string    = "postgresql://${module.postgresql.administrator_login}:${module.postgresql.administrator_password}@${module.postgresql.server_fqdn}:5432/${module.postgresql.database_name}"

  extra_secrets = {
    "agent-vm-ssh-private-key" = module.agent_vm.ssh_private_key_pem
  }

  depends_on = [module.networking]
}

# --- 8. Backend on Azure Container Instances (private) -----------------------
# NOTE on DBDIALECT=postgres: sample-node-app ships only mysql/mysql2 in
# package.json. The backend pipeline (pipelines/app-backend-azure-pipelines.yml
# in that repo, or see docs/RUNBOOK.md) adds pg + pg-hstore before building the
# image so Sequelize can actually speak to this Postgres server.
# NOTE on APPLICATION_HOST: the repo's own .env ships "127.0.0.1", which would
# make the app unreachable from outside its own container. It is overridden
# to 0.0.0.0 below - this is not optional.
module "aci_backend" {
  source                = "../../modules/aci"
  container_group_name  = "aci-empapp-backend"
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  tags                  = local.tags
  aci_subnet_id         = module.networking.aci_subnet_id
  acr_id                = module.acr.id
  acr_login_server      = module.acr.login_server
  container_port        = var.backend_container_port

  environment_variables = {
    APPLICATION_HOST = "0.0.0.0"
    APPLICATION_PORT = tostring(var.backend_container_port)
    NODE_ENV          = "production"
    DBHOST            = module.postgresql.server_fqdn
    DBPORT            = "5432"
    DBNAME            = module.postgresql.database_name
    DBUSERNAME        = module.postgresql.administrator_login
    DBDIALECT         = "postgres"
    WHITELIST_URLS    = jsonencode([var.frontend_origin])
  }

  secure_environment_variables = {
    DBPASSWORD = module.postgresql.administrator_password
  }

  depends_on = [module.postgresql, module.networking]
}

# --- 9. Azure DevOps project/pipelines/service connections (optional) -------
module "azuredevops" {
  count  = var.manage_azure_devops ? 1 : 0
  source = "../../modules/azuredevops"

  providers = {
    azuredevops = azuredevops
  }

  subscription_id               = var.subscription_id
  subscription_name             = var.azdo_subscription_name
  tenant_id                     = var.azdo_tenant_id
  sp_client_id                  = var.azdo_sp_client_id
  sp_client_secret              = var.azdo_sp_client_secret
  acr_name                      = module.acr.name
  acr_resource_group            = azurerm_resource_group.this.name
  github_org                    = var.azdo_github_org
  github_service_connection_pat = var.azdo_github_service_connection_pat
}
