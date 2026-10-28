variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Version of Kubernetes."
  type        = string
  default     = "1.28.3"
}

variable "default_node_pool" {
  description = "Configuration for the system node pool."
  type = object({
    name                = string
    vm_size             = string
    node_count          = optional(number, 2)
    enable_auto_scaling = optional(bool, true)
    min_count           = optional(number, 1)
    max_count           = optional(number, 5)
    os_disk_size_gb     = optional(number, 128)
    vnet_subnet_id      = string
  })
}

variable "additional_node_pools" {
  description = "Map of user/workload node pools with scaling and custom labels/taints."
  type = map(object({
    vm_size             = string
    node_count          = optional(number, 2)
    enable_auto_scaling = optional(bool, true)
    min_count           = optional(number, 1)
    max_count           = optional(number, 10)
    os_disk_size_gb     = optional(number, 128)
    vnet_subnet_id      = string
    node_labels         = optional(map(string), {})
    node_taints         = optional(list(string), [])
    mode                = optional(string, "User")
  }))
  default = {}
}

variable "network_profile" {
  description = "Network profile settings for AKS."
  type = object({
    network_plugin    = string
    network_policy    = optional(string, "azure")
    load_balancer_sku = optional(string, "standard")
    service_cidr      = optional(string, "10.0.0.0/16")
    dns_service_ip    = optional(string, "10.0.0.10")
  })
  default = {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip    = "10.0.0.10"
  }
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for Azure Monitor integration (optional)."
  type        = string
  default     = null
}

variable "enable_secret_store_csi_driver" {
  description = "Enable Azure Key Vault Secrets Store CSI Driver."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all AKS resources."
  type        = map(string)
  default     = {}
}

