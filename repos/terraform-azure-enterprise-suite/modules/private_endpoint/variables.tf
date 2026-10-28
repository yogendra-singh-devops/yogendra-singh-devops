variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "endpoints" {
  description = "Map of private endpoints to configure."
  type = map(object({
    subnet_id              = string
    target_resource_id     = string
    subresource_names      = list(string)
    private_dns_zone_ids   = optional(list(string), [])
    is_manual_connection   = optional(bool, false)
    request_message        = optional(string, null)
  }))
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}

