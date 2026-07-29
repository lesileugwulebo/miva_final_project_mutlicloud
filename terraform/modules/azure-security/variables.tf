variable "resource_group_name" {
  type        = string
  description = "The name of the Azure resource group"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy resources in"
}

variable "aws_vpc_cidr" {
  type        = string
  description = "The CIDR block of the AWS VPC for cross-cloud access"
  default     = "192.168.0.0/20"
}

variable "web_subnet_id" {
  type        = string
  description = "The ID of the Web subnet"
}

variable "app_subnet_id" {
  type        = string
  description = "The ID of the App subnet"
}

variable "db_subnet_id" {
  type        = string
  description = "The ID of the DB subnet"
}

variable "mgmt_subnet_id" {
  type        = string
  description = "The ID of the Mgmt subnet"
}
