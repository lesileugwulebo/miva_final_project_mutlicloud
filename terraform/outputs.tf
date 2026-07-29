output "aws_vpc_id" {
  value       = module.aws_network.vpc_id
  description = "The ID of the AWS VPC"
}

output "aws_subnets" {
  value = {
    web  = module.aws_network.web_subnet_id
    app  = module.aws_network.app_subnet_id
    db   = module.aws_network.db_subnet_id
    mgmt = module.aws_network.mgmt_subnet_id
  }
  description = "The IDs of the AWS subnets"
}

output "azure_vnet_id" {
  value       = module.azure_network.vnet_id
  description = "The ID of the Azure VNet"
}

output "azure_subnets" {
  value = {
    web  = module.azure_network.web_subnet_id
    app  = module.azure_network.app_subnet_id
    db   = module.azure_network.db_subnet_id
    mgmt = module.azure_network.mgmt_subnet_id
  }
  description = "The IDs of the Azure subnets"
}

output "aws_vpn_outside_ips" {
  value       = module.aws_connectivity.vpn_outside_ips
  description = "The public IPs of the AWS VPN tunnels"
}

output "azure_vpn_gateway_ips" {
  value       = module.azure_connectivity.vpn_gateway_public_ips
  description = "The public IPs of the Azure VPN gateway"
}
