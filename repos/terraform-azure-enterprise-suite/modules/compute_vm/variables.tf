variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "vms" {
  description = "Map of Linux VMs to create with their configurations."
  type = map(object({
    vm_size              = string
    admin_username       = string
    ssh_public_key       = string
    subnet_id            = string
    private_ip_address   = optional(string, null)
    os_disk_caching      = optional(string, "ReadWrite")
    os_disk_storage_type = optional(string, "Premium_LRS")
    os_disk_size_gb      = optional(number, 64)
    image_publisher      = optional(string, "Canonical")
    image_offer          = optional(string, "0001-com-ubuntu-server-jammy")
    image_sku            = optional(string, "22_04-lts-gen2")
    image_version        = optional(string, "latest")
    custom_data          = optional(string, null)
  }))
}

variable "tags" {
  description = "Tags applied to VM resources."
  type        = map(string)
  default     = {}
}

