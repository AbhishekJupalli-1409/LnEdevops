subscription_id = "10da8572-3fc9-4bbf-b4c0-6494b847325b"

location            = "centralindia"
resource_group_name = "rg-empapp-centralindia"

business_unit = "EmployeeApps"
cost_center   = "CC-0001"

allowed_locations      = ["centralindia", "southindia", "westindia"]
backend_container_port = 8000

# Placeholder until step 3 (nginx ingress) hands out a public IP - see
# docs/RUNBOOK.md. Update and re-apply once you know the real value.
frontend_origin = "http://REPLACE-WITH-INGRESS-PUBLIC-IP"

# --- Required regardless of manage_azure_devops below: the private agent VM
# (module.agent_vm) registers itself against this org/pool using this PAT,
# because kubectl/helm/flux steps can't run on Microsoft-hosted agents
# against a private AKS API server. Create the org manually first (the one
# allowed manual step), then a PAT with "Agent Pools (read & manage)" scope.
azdo_org_service_url       = "https://dev.azure.com/jupalliabhishek1409"
azdo_personal_access_token = "" # export TF_VAR_azdo_personal_access_token instead of committing this
azdo_agent_pool_name       = "empapp-private-pool"

# --- Optional: also let Terraform manage the Azure DevOps project/pipelines/
# service connections (module.azuredevops) ----------------------------------
manage_azure_devops = false
# azdo_github_org                    = "your-github-org-or-user"
# azdo_github_service_connection_pat = ""
# azdo_sp_client_id                  = ""
# azdo_sp_client_secret              = ""
# azdo_tenant_id                     = ""
# azdo_subscription_name             = "your-subscription-display-name"
