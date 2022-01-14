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
resource "azurerm_resource_group" "multi_rg" {
  name     = "multi-RG"
  location = var.node_location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "multi_vnet" {
  name                = "multi-vnet"
  resource_group_name = azurerm_resource_group.multi_rg.name
  location            = var.node_location
  address_space       = var.node_address_space
}

# Create a subnets within the virtual network
resource "azurerm_subnet" "multi_subnet" {
  name                 = "multi-subnet"
  resource_group_name  = azurerm_resource_group.multi_rg.name
  virtual_network_name = azurerm_virtual_network.multi_vnet.name
  address_prefixes       = var.node_address_prefixes
}

# Create Linux Public IP
resource "azurerm_public_ip" "multi_public_ip" {
  count = var.node_count
  name  = "multi-${format("%02d", count.index)}-PublicIP"
  #name = "multi-PublicIP"
  location            = azurerm_resource_group.multi_rg.location
  resource_group_name = azurerm_resource_group.multi_rg.name
  allocation_method   = "Dynamic"

  tags = {
    Environment = "multi"
  }
}

# Create Network Interface
resource "azurerm_network_interface" "multi_nic" {
  count = var.node_count
  #name = "multi-NIC"
  name                = "multi-${format("%02d", count.index)}-NIC"
  location            = azurerm_resource_group.multi_rg.location
  resource_group_name = azurerm_resource_group.multi_rg.name
  #

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.multi_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.multi_public_ip.*.id, count.index)
    #public_ip_address_id = azurerm_public_ip.multi_public_ip.id
    #public_ip_address_id = azurerm_public_ip.multi_public_ip.id
  }
}


# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "multi_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.multi_subnet.id
  network_security_group_id = azurerm_network_security_group.multi_nsg.id

}

# Virtual Machine Creation — Linux
resource "azurerm_linux_virtual_machine" "multi_linux_vm" {
  count = var.node_count
  name  = "multi-${format("%02d", count.index)}"
  #name = "multi-VM"
  location                      = azurerm_resource_group.multi_rg.location
  resource_group_name           = azurerm_resource_group.multi_rg.name
  network_interface_ids         = [element(azurerm_network_interface.multi_nic.*.id, count.index)]
  size                          = "Standard_A1_v2"
  admin_username                = "Azure"
  #priority = "multi"
  #eviction_policy = "Deallocate"
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
    environment = "multi"
  }
}
