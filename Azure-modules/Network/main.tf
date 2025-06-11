########################################
# Azure VNet Production-Grade Module
########################################

locals {
  public_subnet_name_prefix  = "Public-Subnet"
  private_subnet_name_prefix = "Private-Subnet"
  route_table_name_prefix    = "Route-Table"
  nsg_name_prefix            = "NSG"
}

#----------------------
# VNet
#----------------------
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

#----------------------
# Subnets
#----------------------
resource "azurerm_subnet" "public" {
  count                = length(var.public_subnet_prefixes)
  name = count.index == 0 ? "AzureBastionSubnet" : "${local.public_subnet_name_prefix}-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.public_subnet_prefixes[count.index]]
}

resource "azurerm_subnet" "private" {
  count                = length(var.private_subnet_prefixes)
  name                 = "${local.private_subnet_name_prefix}-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.private_subnet_prefixes[count.index]]
}

#----------------------
# NSGs
#----------------------
resource "azurerm_network_security_group" "public" {
  name                = "${local.nsg_name_prefix}-Public"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "private" {
  name                = "${local.nsg_name_prefix}-Private"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowRDPFromVNet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

#----------------------
# NSG Associations
#----------------------
resource "azurerm_subnet_network_security_group_association" "public" {
  count = length(azurerm_subnet.public) > 1 ? length(azurerm_subnet.public) - 1 : 0

  subnet_id = azurerm_subnet.public[count.index + 1].id
  network_security_group_id = azurerm_network_security_group.public.id
}


resource "azurerm_subnet_network_security_group_association" "private" {
  count                     = length(azurerm_subnet.private)
  subnet_id                = azurerm_subnet.private[count.index].id
  network_security_group_id = azurerm_network_security_group.private.id
}