variable "resource_group_name" {
  type        = string
  description = "The name of the Azure resource group"
  default     = "multicloud-rg"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy resources in"
  default     = "East US"
}

variable "vnet_name" {
  type        = string
  description = "The name of the Azure Virtual Network"
  default     = "multicloud-hub-vnet"
}

variable "vnet_cidr" {
  type        = string
  description = "The CIDR block for the Azure VNet"
  default     = "192.168.16.0/20"
}

variable "web_subnet_cidr" {
  type        = string
  description = "The CIDR block for the Web subnet"
  default     = "192.168.17.0/24"
}

variable "app_subnet_cidr" {
  type        = string
  description = "The CIDR block for the App subnet"
  default     = "192.168.18.0/24"
}

variable "db_subnet_cidr" {
  type        = string
  description = "The CIDR block for the DB subnet"
  default     = "192.168.19.0/24"
}

variable "mgmt_subnet_cidr" {
  type        = string
  description = "The CIDR block for the Mgmt subnet"
  default     = "192.168.20.0/24"
}
