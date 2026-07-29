data "azurerm_client_config" "current" {}

resource "azurerm_network_security_group" "web" {
  name                = "web-tier-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-https"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name = "web-tier-nsg"
  }
}

resource "azurerm_network_security_group" "app" {
  name                = "app-tier-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-web-api"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8443"
    source_address_prefix      = "192.168.17.0/24" # Azure Web Subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-aws-cross-cloud-api"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8443"
    source_address_prefix      = var.aws_vpc_cidr # AWS VPC
    destination_address_prefix = "*"
  }

  tags = {
    Name = "app-tier-nsg"
  }
}

resource "azurerm_network_security_group" "db" {
  name                = "db-tier-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-app-postgres"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "192.168.18.0/24" # Azure App Subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-aws-cross-cloud-db"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.aws_vpc_cidr # AWS VPC
    destination_address_prefix = "*"
  }

  tags = {
    Name = "db-tier-nsg"
  }
}

resource "azurerm_network_security_group" "mgmt" {
  name                = "mgmt-tier-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-ssh-mgmt"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "192.168.16.0/20" # internal VNet only
    destination_address_prefix = "*"
  }

  tags = {
    Name = "mgmt-tier-nsg"
  }
}

# Subnet associations
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = var.web_subnet_id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = var.app_subnet_id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = var.db_subnet_id
  network_security_group_id = azurerm_network_security_group.db.id
}

resource "azurerm_subnet_network_security_group_association" "mgmt" {
  subnet_id                 = var.mgmt_subnet_id
  network_security_group_id = azurerm_network_security_group.mgmt.id
}

# Azure Key Vault for at-rest and secrets encryption
resource "azurerm_key_vault" "vault" {
  name                        = "multicloud-keyvault-01"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "Create", "Delete", "List", "Update"
    ]

    secret_permissions = [
      "Get", "Set", "Delete", "List"
    ]
  }

  tags = {
    Environment = "multicloud-project"
  }
}

# Workload identity for Azure AD to federate with AWS IAM
resource "azurerm_user_assigned_identity" "workload_identity" {
  name                = "azure-workload-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = {
    Environment = "multicloud-project"
  }
}
