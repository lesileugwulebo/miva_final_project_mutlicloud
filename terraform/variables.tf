variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "aws_availability_zone" {
  type        = string
  description = "The AWS availability zone for the subnets"
  default     = "us-east-1a"
}

variable "azure_location" {
  type        = string
  description = "The Azure region to deploy resources in"
  default     = "East US"
}

variable "azure_resource_group_name" {
  type        = string
  description = "The name of the Azure Resource Group"
  default     = "multicloud-rg"
}
