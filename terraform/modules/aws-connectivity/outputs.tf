output "tgw_id" {
  value       = aws_ec2_transit_gateway.tgw.id
  description = "The ID of the AWS Transit Gateway"
}

output "vpn_connection_id" {
  value       = aws_vpn_connection.vpn.id
  description = "The ID of the AWS VPN Connection"
}

output "vpn_outside_ips" {
  value       = [aws_vpn_connection.vpn.tunnel1_address, aws_vpn_connection.vpn.tunnel2_address]
  description = "The public IPs of the AWS VPN tunnels to configure on the Azure side"
}

output "vpn_tunnel1_address" {
  value       = aws_vpn_connection.vpn.tunnel1_address
  description = "Public IP of VPN Tunnel 1"
}

output "vpn_tunnel2_address" {
  value       = aws_vpn_connection.vpn.tunnel2_address
  description = "Public IP of VPN Tunnel 2"
}

output "vpn_tunnel1_bgp_asn" {
  value       = var.aws_tgw_asn
  description = "The BGP ASN of the AWS TGW side"
}
