########################################
# Variables
########################################

variable "instance_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "instance_subnet_id" {
  description = "Subnet ID for the VM"
  type        = string
}

variable "instance_type" {
  description = "VM size (e.g., Standard_D2s_v3)"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "image_sku" {
  description = "Windows image SKU (e.g., 2022-Datacenter)"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the OS disk in GB"
  type        = number
}

variable "root_volume_type" {
  description = "Type of OS disk (e.g., Standard_LRS, Premium_LRS)"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}