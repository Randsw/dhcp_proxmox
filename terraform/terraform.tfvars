proxmox_host            = "https://10.1.1.1:8006/api2/json"
proxmox_token_id        = "root@pam!terraform"
proxmox_storage         = "local-lvm"              # proxmox storage lvm 1
target_node_name        = "proxmox"
region                  = "CAPI"                    # proxmox cluster name
pool                    = "prod"                    # proxmox pool for vms
dhcp_server_ip           = "10.1.1.212"
cores                   = 1
ram                     = 2048
disk_size               = "20G"
dhcp_vm_template         = "ubuntu-jammy-docker"

