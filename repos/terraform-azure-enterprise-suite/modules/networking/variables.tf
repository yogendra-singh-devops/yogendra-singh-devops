variable "resource_group_name" {
  description = "Name of the target Azure Resource Group."
  type        = string
}

variable "location" {
  description = "Azure region where network resources will be deployed."
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network."
  type        = string
}

variable "address_space" {
  description = "CIDR block(s) for the Virtual Network."
  type        = list(string)
}

variable "dns_servers" {
  description = "Custom DNS servers for the VNet (optional)."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Map of subnets to create with CIDR, service endpoints, and optional delegation."
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, false)
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }), null)
  }))
}

variable "nsg_rules" {
  description = "Map of Network Security Rules using dynamic blocks."
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string, "*")
    source_port_ranges         = optional(list(string), null)
    destination_port_range     = optional(string, null)
    destination_port_ranges    = optional(list(string), null)
    source_address_prefix      = optional(string, null)
    source_address_prefixes   = optional(list(string), null)
    destination_address_prefix = optional(string, null)
    destination_address_prefixes = optional(list(string), null)
    description                = optional(string, "Managed by Terraform")
  }))
  default = {}
}

variable "custom_routes" {
  description = "Map of custom routes for the Route Table (e.g. NextHop to Azure Firewall/NVA)."
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string, null)
  }))
  default = {}
}

variable "tags" {
  description = "Common tags applied to all network resources."
  type        = map(string)
  default     = {}
}

