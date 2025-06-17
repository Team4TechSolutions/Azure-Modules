variable "prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "environment" {
  type        = string
  description = "Environment (dev, prod, staging)"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
}

variable "location_short" {
  type        = string
  description = "Short code for location (e.g. 'eus' for East US)"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID"
}

variable "custom_name" {
  type        = string
  default     = null
  description = "Custom name for Key Vault (overrides naming convention)"
}

variable "sku_name" {
  type        = string
  default     = "standard"
  description = "SKU name (standard or premium)"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be either 'standard' or 'premium'."
  }
}

variable "enabled_for_deployment" {
  type        = bool
  default     = false
  description = "Allow Virtual Machines to retrieve certificates"
}

variable "enabled_for_disk_encryption" {
  type        = bool
  default     = false
  description = "Allow Disk Encryption to retrieve secrets"
}

variable "enabled_for_template_deployment" {
  type        = bool
  default     = false
  description = "Allow Resource Manager to retrieve secrets"
}

variable "enable_rbac_authorization" {
  type        = bool
  default     = true
  description = "Use RBAC for authorization instead of access policies"
}

variable "purge_protection_enabled" {
  type        = bool
  default     = true
  description = "Enable purge protection"
}

variable "soft_delete_retention_days" {
  type        = number
  default     = 90
  description = "Soft delete retention period in days (7-90)"

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Retention days must be between 7 and 90."
  }
}

variable "network_acls" {
  type = object({
    default_action             = string
    bypass                     = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default     = null
  description = "Network ACLs configuration"
}

variable "principal_ids" {
  type        = list(string)
  default     = []
  description = "List of principal IDs for RBAC assignments"
}

variable "default_role" {
  type        = string
  default     = "Key Vault Secrets Officer"
  description = "Default RBAC role for principal access"
}

variable "private_endpoint_enabled" {
  type        = bool
  default     = false
  description = "Enable private endpoint"
}

variable "private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for private endpoint"
}

variable "private_dns_zone_ids" {
  type        = list(string)
  default     = []
  description = "List of private DNS zone IDs for private endpoint"
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Log Analytics workspace ID for diagnostics"
}

variable "diagnostics_storage_account_id" {
  type        = string
  default     = null
  description = "Storage account ID for diagnostics"
}

variable "diagnostic_categories" {
  type        = list(string)
  default     = ["AuditEvent"]
  description = "List of diagnostic categories to enable. For Key Vault, only 'AuditEvent' is available."
  
  validation {
    condition     = length(var.diagnostic_categories) == 0 || (length(var.diagnostic_categories) == 1 && var.diagnostic_categories[0] == "AuditEvent")
    error_message = "Key Vault only supports the 'AuditEvent' diagnostic category."
  }
}

variable "diagnostic_retention_enabled" {
  type        = bool
  default     = true
  description = "Enable diagnostic retention policy"
}

variable "diagnostic_retention_days" {
  type        = number
  default     = 30
  description = "Number of days to retain diagnostics"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for resources"
}


variable "use_access_policies" {
  type        = bool
  default     = false
  description = "If true, use Key Vault access policies instead of RBAC"
}

variable "access_policies" {
  type = list(object({
    tenant_id              = string
    object_id              = string
    secret_permissions     = list(string)
    key_permissions        = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
  }))
  default     = []
  description = "List of access policy objects to assign when use_access_policies = true"
}

variable "enable_diagnostics" {
  type        = bool
  default     = false
  description = "Enable diagnostic settings for Key Vault"
}
