output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the Azure resource group"
}

output "location" {
  value       = azurerm_resource_group.rg.location
  description = "The Azure location region"
}

output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The ID of the Azure VNet"
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "The name of the Azure VNet"
}

output "web_subnet_id" {
  value       = azurerm_subnet.web.id
  description = "The ID of the Web subnet"
}

output "app_subnet_id" {
  value       = azurerm_subnet.app.id
  description = "The ID of the App subnet"
}

output "db_subnet_id" {
  value       = azurerm_subnet.db.id
  description = "The ID of the DB subnet"
}

output "mgmt_subnet_id" {
  value       = azurerm_subnet.mgmt.id
  description = "The ID of the Mgmt subnet"
}

output "vnet_cidr_block" {
  value       = azurerm_virtual_network.vnet.address_space[0]
  description = "The CIDR block of the Azure VNet"
}
