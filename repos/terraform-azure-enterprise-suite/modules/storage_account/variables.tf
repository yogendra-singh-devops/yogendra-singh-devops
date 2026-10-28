variable "storage_account_name" {
  description = "The globally unique name of the Azure Storage Account."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for deployment."
  type        = string
}

variable "account_tier" {
  description = "Tier to use for this storage account (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Replication type (LRS, GRS, RAGRS, ZRS, GZRS)."
  type        = string
  default     = "GRS"
}

variable "min_tls_version" {
  description = "Minimum TLS version required."
  type        = string
  default     = "TLS1_2"
}

variable "network_rules" {
  description = "Firewall and virtual network configurations for the storage account."
  type = object({
    default_action             = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
    bypass                     = optional(list(string), ["AzureServices"])
  })
  default = {
    default_action = "Deny"
    ip_rules       = []
    bypass         = ["AzureServices"]
  }
}

variable "blob_retention_days" {
  description = "Number of days to retain deleted blobs for soft delete."
  type        = number
  default     = 14
}

variable "containers" {
  description = "Map of blob containers to provision with their access levels."
  type = map(object({
    container_access_type = optional(string, "private")
    metadata              = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}

