variable "allowed_locations" {
  type    = list(string)
  default = ["centralindia", "southindia", "westindia"]
}

variable "excluded_scopes" {
  description = "Scopes exempt from the tag Deny policies. The AKS MC_ resource group creates untagged node resources."
  type        = list(string)
  default     = []
}

variable "department_tag_name" {
  type    = string
  default = "Department"
}

variable "project_code_tag_name" {
  type    = string
  default = "Project Code"
}
