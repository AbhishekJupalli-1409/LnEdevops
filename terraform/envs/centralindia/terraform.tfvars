subscription_id = "10da8572-3fc9-4bbf-b4c0-6494b847325b"

location            = "centralindia"
resource_group_name = "rg-empapp-centralindia"

business_unit = "EmployeeApps"
cost_center   = "CC-0001"

allowed_locations      = ["centralindia", "southindia", "westindia"]
backend_container_port = 8000

# Ingress-nginx public IP (CORS WHITELIST_URLS for the ACI backend).
frontend_origin = "http://4.224.111.37"

# --- Required regardless of manage_azure_devops below: the private agent VM
# (module.agent_vm) registers itself against this org/pool using a PAT,
# because kubectl/helm/flux steps can't run on Microsoft-hosted agents
# against a private AKS API server. Create the org manually first (the one
# allowed manual step), then a PAT with "Agent Pools (read & manage)" scope.
# Do NOT set azdo_personal_access_token here (even to ""). terraform.tfvars
# beats TF_VAR_*, so an empty assignment wipes the pipeline secret and the
# agent config fails with "Invalid configuration provided for token".
azdo_org_service_url = "https://dev.azure.com/jupalliabhishek1409"
azdo_agent_pool_name = "empapp-private-pool"

# --- Optional: also let Terraform manage the Azure DevOps project/pipelines/
# service connections (module.azuredevops) ----------------------------------
# SP now has Resource Policy Contributor — set true to create the 3 policies.
enable_policy_assignments = false

manage_azure_devops = false
# azdo_github_org                    = "your-github-org-or-user"
# azdo_github_service_connection_pat = ""
# azdo_sp_client_id                  = ""
# azdo_sp_client_secret              = ""
# azdo_tenant_id                     = ""
# azdo_subscription_name             = "your-subscription-display-name"
