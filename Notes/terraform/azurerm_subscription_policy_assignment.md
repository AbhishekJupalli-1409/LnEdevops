# azurerm_subscription_policy_assignment

## Brief introduction

Azure Policy **assignments** attach a policy definition to a scope (here: the subscription). They audit or deny non-compliant resources.

## Why we create it

Guardrails so the platform cannot drift into wrong regions, missing cost tags, or public NICs.

## How Terraform creates it

Module: `terraform/modules/policy/main.tf` — four built-in definition assignments:

1. Allowed locations (India regions)
2. Require tag `Business Unit`
3. Require tag `Cost Center`
4. Deny public IP on NICs

```hcl
resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  subscription_id      = data.azurerm_subscription.current.id
  # parameters: listOfAllowedLocations
}
```

## Use in this project

Subscription-wide compliance before/while creating networking and compute.

## Example to understand

Like company rules: “You may only build in India” and “Every resource must have Cost Center.” Terraform assigns those rules once; Azure enforces them on create/update.
