data "azurerm_public_ip" "spot_public_ip" {
  count               = "${var.node_count}"
  name                = "${element(azurerm_public_ip.spot_public_ip.*.name, count.index)}"
  resource_group_name = "${azurerm_resource_group.spot_rg.name}"
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.spot_linux_vm[*].public_ip_address
}

resource "null_resource" "azurerm_ip" {
  provisioner "local-exec" {
     command = "sleep 180 && az vm list-ip-addresses --query '[].virtualMachine.network.publicIpAddresses[0].ipAddress' --output tsv > hosts.tsv"
  }
}
resource "null_resource" "inventory" {
    triggers = {
    order = null_resource.azurerm_ip.id
  }

  provisioner "local-exec" {
     command = "/bin/bash ./INVENTORY-CREATE.sh"
  }
}
# Runs an ansible playbook after provisioning
# resource "null_resource" "playbook" {
#     triggers = {
#     order = null_resource.inventory.id
#   }
  
#   provisioner "local-exec" {
#      command = "ansible-playbook facts.yml -u Azure"
#   }
# }


















