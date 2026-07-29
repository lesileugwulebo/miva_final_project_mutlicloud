variable "resource_group_name" {
  type        = string
  description = "The name of the Azure resource group"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy resources in"
}

variable "vnet_id" {
  type        = string
  description = "The ID of the Azure VNet"
}

variable "aws_vpn_outside_ips" {
  type        = list(string)
  description = "The public IPs of the AWS VPN tunnels"
  default     = ["198.51.100.1", "198.51.100.2"] # placeholders for compilation/simulation
}

variable "aws_tgw_asn" {
  type        = number
  description = "The BGP ASN of the AWS TGW side"
  default     = 64512
}

variable "azure_bgp_asn" {
  type        = number
  description = "The BGP ASN of the Azure side"
  default     = 65515
}
