variable "environment" {
  description = "Target deployment environment (e.g. prod, staging)."
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Target Azure Region."
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name prefix."
  type        = string
  default     = "enterprise"
}

variable "tenant_id" {
  description = "Microsoft Entra ID Tenant ID."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH Public Key for Linux compute instances."
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Standard enterprise tag taxonomy."
  type        = map(string)
  default = {
    Environment = "Production"
    Owner       = "Yogendra Singh (DevOps)"
    ManagedBy   = "Terraform"
    CostCenter  = "Cloud-Infra-101"
  }
}

