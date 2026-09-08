# azurerm_container_group

## Brief introduction

**Azure Container Instances (ACI)** runs containers without managing VMs/orchestrators. A container group is one or more containers sharing a network lifecycle.

## Why we create it

Run the Node employee **backend** privately in the VNet (simpler than putting API on AKS for this design), reachable from AKS frontend pods via private IP.

## How Terraform creates it

```hcl
resource "azurerm_container_group" "backend" {
  name                = "aci-emp-backend"
  os_type             = "Linux"
  subnet_ids          = [var.aci_subnet_id]
  ip_address_type     = "Private"
  # image from ACR, env for DB, identity for pull
}
```

## Use in this project

Private backend API; NSG allows AKS → backend port only.

## Example to understand

A small private “API appliance” plugged into `snet-aci`, not exposed on the public internet.
