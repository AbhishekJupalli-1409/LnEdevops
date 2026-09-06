variable "allowed_locations" {
  description = "Azure regions resources are permitted to be deployed into."
  type        = list(string)
  default     = ["centralindia", "southindia", "westindia"]
}
