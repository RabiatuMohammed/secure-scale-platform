resource "azurerm_virtual_network" "platform" {
  name                = "vnet-${var.environment}-platform"
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  address_space       = ["10.0.0.0/16"]


  tags = local.common_tags
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-ask"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefixes     = ["10.0.0.0/22"]


delegation {
  name      = "ask-delegation"
  service_delegation {
    name    = "Microsoft.ContainerService/managedClusters"
    actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action"
    ]
  }
}
}


resource "azurerm_subnet" "appgw" {
  name                  = "snet-appgw"
  resource_group_name   = azurerm_resource_group.platform.name
  virtual_network_name  = azurerm_resource_group.platform.name
  address_prefixes      = ["10.0.4.0/24"]
}


resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_resource_group.platform.name
  address_prefixes     = ["10.0.5.0/24"]
}


resource "azurerm_subnet" "private_endpoints" {
  name                                       = "snet-private-endpoints"
  resource_group_name                        = azurerm_resource_group.platform.name
  virtual_network_name                       = azurerm_virtual_network.platform.name
  address_prefixes                           = ["10.0.6.0/24"]
  
  
  service_endpoints                          = [
    "Microsoft.Storage", 
    Microsoft.KeyVault, 
    Microsoft.ContainerRegistry
    
    ]
}


resource "azurerm_network_security_group" "aks" {
  name                 = "nsg-aks-${var.environment}"
  location             =  azurerm_resource_group.platform.location
  resource_group_name  = azurerm_resource_group.platform.name




security_rule {
    name                          = "AlllowHttpsInbound"
    priority                      = 100
    direction                     = "Inbound"
    access                        = "Allow"
    protocol                      = "Tcp"
    source_port_range             = "*"
    destination_port_range        = "443"
    source_address_prefix         = "AzureLoadBalancer"
    destination_address_prefix    = "*"
  }


  security_rule {
    name                          = "DenyAllInbound"
    priority                      =  4096
    direction                     =  "Inbound"
    access                        =  "Deny"
    protocol                      =   "*"
    source_port_range             =  "*"
    destination_port_range        =  "*"
    source_address_prefix         =  "*"
    destination_address_prefix    =  "*"
  }
}




resource "azurerm_route_table" "aks" {
  name                          = "rt-ask-${var.environment}"
  location                      = azurerm_resource_group.platform.location
  resource_group_name      = azurerm_resource_group.platform.name


  route  {
    name                        = "to-firewall"
    address_prefix              = "0.0.0.0/0"
    next_hop_type               = "VirtualApplication"
    next_hop_in_ip_address      = azurerm_firewall.platform.ip_configuration[0].private_ip_address

  }
}

resource "azurerm_firewall" "platform" {
  name                          = "fw-platform-${var.environment}"
  location                      = azurerm_resource_group.platform.location
  resource_group_name           = azurerm_resource_group.platform.name
  sku_name                      = "AZFW_VNet"
  sku_tier                      = "Standard"


ip_configuration {
  name                           = "fw-ipconfig"
  subnet_id                      = azurerm_subnet.firewall.id
  public_ip_address_id           = azurerm_public_ip.firewall.id
 }
}


resource "azurerm_private_dns_zone" "platform" {
  name                           = "privatelink.azurecr.io"
  resource_group_name            = azurerm_resource_group.platform.name

}

resource "azurerm_private_dns_zone_virtual_network_link" "platform" {
  name                           = "pdnslink-platform"
  resource_group_name            = azurerm_resource_group.platform.name
  private_dns_zone_name          = azurerm_private_dns_zone.platform.name
  virtual_network_id             = azurerm_virtual_network.platform.id
}