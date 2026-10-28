variable "key_vault_name" {
  description = "The globally unique name of the Azure Key Vault."
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

variable "sku_name" {
  description = "SKU used for the Key Vault (standard or premium)."
  type        = string
  default     = "standard"
}

variable "tenant_id" {
  description = "The Microsoft Entra ID tenant ID."
  type        = string
}

variable "purge_protection_enabled" {
  description = "Whether purge protection is enabled for this Key Vault."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Number of days that items should be retained once soft-deleted."
  type        = number
  default     = 90
}

variable "network_acls" {
  description = "Network rule set for Key Vault."
  type = object({
    default_action             = string
    bypass                     = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "access_policies" {
  description = "Map of access policies by object/principal ID."
  type = map(object({
    object_id               = string
    certificate_permissions = optional(list(string), [])
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), ["Get", "List"])
    storage_permissions     = optional(list(string), [])
  }))
  default = {}
}

variable "secrets" {
  description = "Map of initial secrets to store in the Key Vault."
  type = map(object({
    value        = string
    content_type = optional(string, "text/plain")
  }))
  default = {}
}

variable "tags" {
  description = "Tags to attach."
  type        = map(string)
  default     = {}
}

