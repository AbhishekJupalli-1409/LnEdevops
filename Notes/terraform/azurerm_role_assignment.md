# azurerm_role_assignment

## Brief introduction

Assigns an Azure RBAC role (e.g. `AcrPull`, Key Vault Secrets Officer) to an identity on a scope.

## Why we create it

Passwordless access: AKS/ACI pull images; Terraform deployer writes Key Vault secrets — without embedding registry passwords.

## How Terraform creates it

Examples:

```hcl
# AKS kubelet → ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

# ACI UAMI → ACR
resource "azurerm_role_assignment" "aci_acr_pull" { ... }

# Deployer → Key Vault Secrets Officer
resource "azurerm_role_assignment" "deployer_secrets_officer" { ... }
```

## Use in this project

Identity-based security for ACR pulls and Key Vault secret management.

## Example to understand

Giving a badge (“AcrPull”) to a robot identity so it can open the image warehouse door — no shared key under the mat.
