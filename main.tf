# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}


# Create a resource group
resource "azurerm_resource_group" "spot_rg" {
  name     = "mult-spot-RG"
  location = var.node_location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "spot_vnet" {
  name                = "mult-spot-vnet"
  resource_group_name = azurerm_resource_group.spot_rg.name
  location            = var.node_location
  address_space       = var.node_address_space
}

# Create a subnets within the virtual network
resource "azurerm_subnet" "spot_subnet" {
  name                 = "mult-spot-subnet"
  resource_group_name  = azurerm_resource_group.spot_rg.name
  virtual_network_name = azurerm_virtual_network.spot_vnet.name
  address_prefixes       = var.node_address_prefixes
}

# Create Linux Public IP
resource "azurerm_public_ip" "spot_public_ip" {
  count = var.node_count
  name  = "mult-spot-${format("%02d", count.index)}-PublicIP"
  #name = "mult-spot-PublicIP"
  location            = azurerm_resource_group.spot_rg.location
  resource_group_name = azurerm_resource_group.spot_rg.name
  allocation_method   = "Dynamic"

  tags = {
    Environment = "Spot"
  }
}

# Create Network Interface
resource "azurerm_network_interface" "spot_nic" {
  count = var.node_count
  #name = "mult-spot-NIC"
  name                = "mult-spot-${format("%02d", count.index)}-NIC"
  location            = azurerm_resource_group.spot_rg.location
  resource_group_name = azurerm_resource_group.spot_rg.name
  #

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spot_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.spot_public_ip.*.id, count.index)
    #public_ip_address_id = azurerm_public_ip.spot_public_ip.id
    #public_ip_address_id = azurerm_public_ip.spot_public_ip.id
  }
}


# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "spot_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.spot_subnet.id
  network_security_group_id = azurerm_network_security_group.spot_nsg.id

}

# Virtual Machine Creation — Linux
resource "azurerm_linux_virtual_machine" "spot_linux_vm" {
  count = var.node_count
  name  = "mult-spot-${format("%02d", count.index)}"
  #name = "mult-spot-VM"
  location                      = azurerm_resource_group.spot_rg.location
  resource_group_name           = azurerm_resource_group.spot_rg.name
  network_interface_ids         = [element(azurerm_network_interface.spot_nic.*.id, count.index)]
  size                       = "Standard_A1_v2"
  admin_username                = "Azure"
  priority = "Spot"
  eviction_policy = "Deallocate"
  disable_password_authentication = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "Azure"
    public_key = file(var.public_key_path)
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "Spot"
  }
}
