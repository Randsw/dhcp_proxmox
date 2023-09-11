locals {
  inventory_rendered_content = templatefile("${path.module}/inventory_ansible.tftpl", 
  {
    tpl_dhcp_server_ip = "${var.dhcp_server_ip}"
    tpl_vm_user = "${var.vm_user}"
  })
}

resource "local_file" "inventories" {
  content = local.inventory_rendered_content
  filename = "${path.module}/../ansible/inventories/dhcp/hosts.yml"
}