variable "allowed_locations" {
  description = "Azure regions resources are permitted to be deployed into."
  type        = list(string)
  default     = ["centralindia", "southindia", "westindia"]
}

variable "excluded_scopes" {
  description = <<-EOT
    Scopes (e.g. the AKS-managed "MC_" resource group) exempted from the
    Deny policy assignments. AKS creates untagged VMSS/LB/public-IP resources
    there that would otherwise trip the Require-a-tag policies.
  EOT
  type    = list(string)
  default = []
}
