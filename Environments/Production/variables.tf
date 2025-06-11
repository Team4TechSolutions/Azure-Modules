variable "location" {
  type    = string
  default = "canadacentral"
}

variable "resource_group_name" {
  type    = string
  default = "prod-rg"
}

variable "admin_username" {
  type        = string
  description = "Windows VM admin username"
}

variable "admin_password" {
  type        = string
  description = "Windows VM admin password"
  sensitive   = true
}

variable "tags" {
  type    = map(string)
  default = {
    environment = "production"
    owner       = "team4tech"
  }
}


variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}
