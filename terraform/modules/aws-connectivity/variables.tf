variable "vpc_id" {
  type        = string
  description = "The ID of the AWS VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnets to associate with the Transit Gateway attachment"
}

variable "azure_vpn_gateway_ip" {
  type        = string
  description = "The public IP address of the Azure VPN Gateway"
  default     = "203.0.113.10" # placeholder for compilation/simulation
}

variable "azure_vnet_cidr" {
  type        = string
  description = "The CIDR block of the Azure VNet"
  default     = "192.168.16.0/20"
}

variable "aws_tgw_asn" {
  type        = number
  description = "The BGP Autonomous System Number (ASN) for AWS Transit Gateway"
  default     = 64512
}

variable "azure_bgp_asn" {
  type        = number
  description = "The BGP Autonomous System Number (ASN) for Azure Virtual WAN / VPN Gateway"
  default     = 65515
}

variable "route_table_ids" {
  type        = list(string)
  description = "List of Route Table IDs to add the Azure VNet route to"
}
