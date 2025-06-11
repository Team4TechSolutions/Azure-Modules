#----------------------
# Variables
#----------------------
variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "public_subnet_prefixes" {
  description = "CIDR prefixes for public subnets"
  type        = list(string)
}

variable "private_subnet_prefixes" {
  description = "CIDR prefixes for private subnets"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
