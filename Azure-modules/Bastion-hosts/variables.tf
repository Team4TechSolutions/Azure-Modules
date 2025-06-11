########################################
# Variables
########################################

variable "bastion_name" {
  description = "Name of the Azure Bastion host"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the public subnet named AzureBastionSubnet"
  type        = string
  default = "AzureBastionSubnet"
}

variable "dns_name" {
  description = "Optional DNS name label for the Bastion public IP"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}