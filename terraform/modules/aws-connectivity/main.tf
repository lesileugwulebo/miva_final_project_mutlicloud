resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "AWS Transit Gateway for Multi-Cloud Connectivity"
  amazon_side_asn                 = var.aws_tgw_asn
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "multicloud-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attach" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc_id

  tags = {
    Name = "tgw-vpc-attachment"
  }
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn    = var.azure_bgp_asn
  ip_address = var.azure_vpn_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name = "azure-vpn-cgw"
  }
}

resource "aws_vpn_connection" "vpn" {
  transit_gateway_id    = aws_ec2_transit_gateway.tgw.id
  customer_gateway_id   = aws_customer_gateway.cgw.id
  type                  = "ipsec.1"
  static_routes_only    = false # Enable BGP routing

  # Tunnel configurations for strong IPsec properties (IKEv2, AES-256-GCM)
  tunnel1_ike_versions = ["ikev2"]
  tunnel1_phase1_dh_group_numbers = [14]
  tunnel1_phase2_dh_group_numbers = [14]
  tunnel1_phase1_encryption_algorithms = ["AES256-GCM-16"]
  tunnel1_phase2_encryption_algorithms = ["AES256-GCM-16"]
  tunnel1_phase1_integrity_algorithms = ["SHA2-256"]
  tunnel1_phase2_integrity_algorithms = ["SHA2-256"]

  tunnel2_ike_versions = ["ikev2"]
  tunnel2_phase1_dh_group_numbers = [14]
  tunnel2_phase2_dh_group_numbers = [14]
  tunnel2_phase1_encryption_algorithms = ["AES256-GCM-16"]
  tunnel2_phase2_encryption_algorithms = ["AES256-GCM-16"]
  tunnel2_phase1_integrity_algorithms = ["SHA2-256"]
  tunnel2_phase2_integrity_algorithms = ["SHA2-256"]

  tags = {
    Name = "aws-to-azure-vpn"
  }
}

# Route to route Azure traffic to the Transit Gateway from the VPC
resource "aws_route" "azure_route" {
  count                  = length(var.route_table_ids)
  route_table_id         = var.route_table_ids[count.index]
  destination_cidr_block = var.azure_vnet_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}
