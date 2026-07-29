variable "vpc_id" {
  type        = string
  description = "The ID of the AWS VPC"
}

variable "azure_vnet_cidr" {
  type        = string
  description = "The CIDR block of the Azure VNet for cross-cloud access"
  default     = "192.168.16.0/20"
}
