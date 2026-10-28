variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "dns_zones" {
  description = "List of Private DNS Zone names to provision."
  type        = list(string)
  default = [
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.database.windows.net",
    "privatelink.azurecr.io"
  ]
}

variable "vnet_links" {
  description = "Map of VNets to link with Private DNS Zones (name => vnet_id)."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}

