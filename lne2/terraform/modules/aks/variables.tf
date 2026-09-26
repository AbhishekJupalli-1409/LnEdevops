variable "cluster_name" { type = string }
variable "dns_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "aks_subnet_id" { type = string }
variable "acr_id" { type = string }
variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}
variable "node_count" {
  type    = number
  default = 1
}
variable "kubernetes_version" {
  type    = string
  default = null
}
variable "pod_cidr" { type = string }
variable "service_cidr" { type = string }
variable "dns_service_ip" { type = string }
variable "tags" { type = map(string) }
