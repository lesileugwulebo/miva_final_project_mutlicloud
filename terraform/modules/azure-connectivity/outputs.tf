output "vpn_gateway_id" {
  value       = azurerm_vpn_gateway.gateway.id
  description = "The ID of the Azure VPN Gateway"
}

output "vpn_gateway_public_ips" {
  value       = ["203.0.113.10"]
  description = "The public IPs of the Azure VPN gateway (static placeholder for multi-state simulation)"
}
