data "azurerm_public_ip" "pip" {
  name                = azurerm_public_ip.pip.name
  resource_group_name = azurerm_linux_virtual_machine.main.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.main]
}

output "os_sku" {
  value = lookup(var.sku, var.location)
}

output "public_ip_address" {
  value = data.azurerm_public_ip.pip.ip_address
}


resource "local_file" "inventory" {
  filename = "hosts.ini"
    content     = <<-EOF
    [Azure]
    ${data.azurerm_public_ip.pip.ip_address}

    [all:vars]
    ansible_python_interpreter=/usr/bin/python3
    EOF
}







