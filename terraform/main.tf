module "aws_network" {
  source            = "./modules/aws-network"
  availability_zone = var.aws_availability_zone
}

module "aws_security" {
  source          = "./modules/aws-security"
  vpc_id          = module.aws_network.vpc_id
  azure_vnet_cidr = module.azure_network.vnet_cidr_block
}

module "azure_network" {
  source              = "./modules/azure-network"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
}

module "azure_security" {
  source              = "./modules/azure-security"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  aws_vpc_cidr        = module.aws_network.vpc_cidr_block
  web_subnet_id       = module.azure_network.web_subnet_id
  app_subnet_id       = module.azure_network.app_subnet_id
  db_subnet_id        = module.azure_network.db_subnet_id
  mgmt_subnet_id      = module.azure_network.mgmt_subnet_id
}

module "azure_connectivity" {
  source              = "./modules/azure-connectivity"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  vnet_id             = module.azure_network.vnet_id
  aws_vpn_outside_ips = module.aws_connectivity.vpn_outside_ips
}

module "aws_connectivity" {
  source               = "./modules/aws-connectivity"
  vpc_id               = module.aws_network.vpc_id
  subnet_ids           = [module.aws_network.mgmt_subnet_id] # TGW VPC attachment subnet
  azure_vpn_gateway_ip = module.azure_connectivity.vpn_gateway_public_ips[0]
  azure_vnet_cidr      = module.azure_network.vnet_cidr_block
  route_table_ids      = [module.aws_network.public_route_table_id, module.aws_network.private_route_table_id]
}
