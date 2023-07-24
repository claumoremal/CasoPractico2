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
}

//definicion de subred
resource "azurerm_subnet" "subnet" {
  name                 = var.subnetName
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

//definicion de ip publica
resource "azurerm_public_ip" "podmanPublicIP" {
  name                = "podmanPublicIP"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

//definicion de tarjeta de red virtual para conectar el web server contenerizado
resource "azurerm_network_interface" "vnicPodman" {
  name                = "vnic-casoPractico"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.podmanPublicIP.id
  }
}

//definicion de clave ssh para vmPodman
resource "azurerm_ssh_public_key" "sshPodman" {
  name                = "sshPodman"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  public_key          = file("~/.ssh/sshCasoPractico.pub")
}

//definicion vm Centos8 podman
/*resource "azurerm_linux_virtual_machine" "vmPodman" {
  name                = "vmPodman"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = var.sshUser
  network_interface_ids = [
    azurerm_network_interface.vnicPodman.id,
  ]

  admin_ssh_key {
    username   = var.sshUser
    public_key = file(var.sshPublicKey)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "centos-8-stream-free"
    product   = "centos-8-stream-free"
    publisher = "cognosys"
  }




  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-stream-free"
    sku       = "centos-8-stream-free"
    version   = "22.03.28"
  }
}*/

resource "azurerm_linux_virtual_machine" "vmPodman" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "podman"
  network_interface_ids = [
    azurerm_network_interface.vnicPodman.id,
  ]

  admin_ssh_key {
    username   = "podman"
    public_key = file(var.sshPublicKey)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "centos-8-stream-free"
    product   = "centos-8-stream-free"
    publisher = "cognosys"
  }


  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-stream-free"
    sku       = "centos-8-stream-free"
    version   = "22.03.28"
  }
}

//definicion y linkeado de network security group para acceder a vmPodman desde ip publica
/*resource "azurerm_network_security_group" "nsgPodman" {
  name                = "nsgPodman"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "httpAllow"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "sshAllow"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-link" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsgPodman.id
}*/

//definicion de container registry con elservicio de azure acr
resource "azurerm_container_registry" "acr" {
  name                = "acrCasoPractico"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}
