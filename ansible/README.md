# DHCP server

## Deploy

### Deploy DHCP server

`ansible-playbook -i inventories/dhcp/hosts.yml -e "ansible_ssh_private_key_file=<path-to-ssh-private-key" dhcp-deploy.yml`
