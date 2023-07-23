//En este fichero se van a definir los recursos de infraestructura a desplegar

//definicion de resource group con el nombre tomado desde el fichero variables.tf
resource "azurerm_resource_group" "rg" {
  name = var.resourceGroupName
  location = var.location
}

//definicion de red virtual
resource "azurerm_virtual_network" "vnet" {
  name                = var.networkName
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  tags = {
    environment = "Production"
  }
}

//definicion de subred
resource "azurerm_subnet" "subnet" {
  name                 = var.subnetName
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

//definicion de ip publica
resource "azurerm_public_ip" "publicIP" {
  name                = "publicIP-casoPractico"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

//definicion de tarjeta de red virtual para conectar el web server contenerizado
resource "azurerm_network_interface" "vnic" {
  name                = "vnic-casoPractico"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

//definicion de container registry con elservicio de azure acr
resource "azurerm_container_registry" "acr" {
  name                = "acrCasoPractico"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}
