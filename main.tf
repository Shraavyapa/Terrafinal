provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
 
# Use existing resource group
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
  #location = "East US"
}

# Virtual network 
resource "azurerm_virtual_network" "vnet" {
  name                = "windows-vnetfinal"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
}
 
# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "windowssubnetfinal"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Generate public ip
/*resource "azurerm_public_ip" "public_ip" {
   name                = "v-ip"
   location            = data.azurerm_resource_group.existing.location
   resource_group_name = data.azurerm_resource_group.existing.name
   allocation_method   = "Static"
}*/
 
# Network interface
resource "azurerm_network_interface" "nic" {
  name                = "windows-nicfinal"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}
 
# VM creation
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "myWindowsVMex"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"
  admin_password      = "azureuser@123"  # Use a secure password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter" 
    version   = "latest"
  }

  # tags
  tags = {
    Environment = "Dev"
    Owner       = "shraavya"
  }
}