resource "azurerm_virtual_wan" "wan" {
  name                = "multicloud-virtual-wan"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags = {
    Name = "multicloud-virtual-wan"
  }
}

resource "azurerm_virtual_hub" "hub" {
  name                = "multicloud-virtual-hub"
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_wan_id      = azurerm_virtual_wan.wan.id
  address_prefix      = "192.168.32.0/24" # Non-overlapping subnet for the hub services

  tags = {
    Name = "multicloud-virtual-hub"
  }
}

resource "azurerm_vpn_gateway" "gateway" {
  name                = "azure-hub-vpn-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  virtual_hub_id      = azurerm_virtual_hub.hub.id

  tags = {
    Name = "azure-hub-vpn-gateway"
  }
}

resource "azurerm_vpn_site" "aws_site" {
  name                = "aws-vpn-site"
  location            = var.location
  resource_group_name = var.resource_group_name
  virtual_wan_id      = azurerm_virtual_wan.wan.id

  # AWS VPN Endpoint details
  link {
    name       = "aws-tunnel1"
    ip_address = var.aws_vpn_outside_ips[0]
    bgp {
      asn             = var.aws_tgw_asn
      peering_address = "169.254.1.1" # AWS standard Tunnel 1 BGP IP
    }
  }

  link {
    name       = "aws-tunnel2"
    ip_address = var.aws_vpn_outside_ips[1]
    bgp {
      asn             = var.aws_tgw_asn
      peering_address = "169.254.2.1" # AWS standard Tunnel 2 BGP IP
    }
  }

  tags = {
    Name = "aws-vpn-site"
  }
}

resource "azurerm_vpn_gateway_connection" "aws_conn" {
  name               = "azure-to-aws-vpn-connection"
  vpn_gateway_id     = azurerm_vpn_gateway.gateway.id
  remote_vpn_site_id = azurerm_vpn_site.aws_site.id

  vpn_link {
    name             = "tunnel1"
    vpn_site_link_id = azurerm_vpn_site.aws_site.link[0].id
    shared_key       = "SuperSecretKey123"
  }

  vpn_link {
    name             = "tunnel2"
    vpn_site_link_id = azurerm_vpn_site.aws_site.link[1].id
    shared_key       = "SuperSecretKey123"
  }
}

resource "azurerm_virtual_hub_connection" "vnet_conn" {
  name                      = "hub-to-spoke-vnet-connection"
  virtual_hub_id            = azurerm_virtual_hub.hub.id
  remote_virtual_network_id = var.vnet_id
}
