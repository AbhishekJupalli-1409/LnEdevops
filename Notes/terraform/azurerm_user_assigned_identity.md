# azurerm_user_assigned_identity

## Brief introduction

A standalone Azure AD identity you attach to resources (UAMI). Survives independently of a single VM/ACI lifecycle.

## Why we create it

ACI needs an identity with `AcrPull` to pull the backend image without admin registry credentials.

## How Terraform creates it

```hcl
resource "azurerm_user_assigned_identity" "aci" {
  name                = "id-aci-backend"
  resource_group_name = var.resource_group_name
  location            = var.location
}
```

## Use in this project

Assigned to the ACI container group; role `AcrPull` on ACR.

## Example to understand

A reusable employee badge for the backend container group, not tied to a human user.
