data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_virtual_machine.vm.resource_group_name
  depends_on          = [azurerm_virtual_machine.vm]
}

output "os_sku" {
  value = lookup(var.sku, var.location)
}

output "public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}

resource "local_file" "inventory" {
  filename = "hosts.ini"
    content     = <<-EOF
    [Azure]
    ${data.azurerm_public_ip.ip.ip_address}

    [all:vars]
    ansible_python_interpreter=/usr/bin/python3
    EOF
}








