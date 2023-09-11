resource "proxmox_vm_qemu" "dns" {
  name        = "dhcp"
  target_node = var.target_node_name
  clone       = var.dhcp_vm_template
  vmid        = var.dhcp_vmid

  agent                   = 1
  define_connection_info  = false
  os_type                 = "cloud-init"
  qemu_os                 = "l26"
  ipconfig0               = "ip=${var.dhcp_server_ip}/24,gw=${var.gateway}"

  #Add public ssh keys in authorized keys
  sshkeys = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFo3L5HfAvV4BYqYY00YSQyr+iyp1IwRAipL9BNQpMc7gUrDMf3WVV12UasvBFU//mBqSAq8v7YQu4k9VI442rFap8jxuL2/AwW9ZlrFvtQiXiD7qTKfyvb3whNvMlgalBN4n20tlqZll6J5G4iiPBzFtkB0F69fvJWrsdeoFmA0LJjqQVRCZulxsbAeSamp4JiWiA6m4ICvLY3vNA1JR1T7MJJ9Noo7a4P1o1ITCIruS6LjWmUlek2k6Uq4X7kf7wv3JXCbvpzh7lSCCzKxTCIU5vwfk5A4UXRLTqdHwuYBfvHiY2W2mLB4C79N0gYkm9wQzphx2/bpsg+VLDOpcH
EOF

  onboot  = false
  cpu     = "kvm64,flags=+aes"
  sockets = 1
  cores   = var.cores
  memory  = var.ram
  scsihw  = "virtio-scsi-pci"

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  boot = "order=scsi0"
  disk {
    slot    = 0
    type    = "scsi"
    storage = var.proxmox_storage
    size    = var.disk_size
    cache   = "writethrough"
    ssd     = 1
    backup  = false
    #https://github.com/Telmate/terraform-provider-proxmox/issues/704
    file    = "vm-${var.dhcp_vmid}-disk-0"
    volume  = "local-lvm:vm-${var.dhcp_vmid}-disk-0"
  }
  lifecycle {
    ignore_changes = [
      boot,
      network,
      desc,
      numa,
      agent,
      ipconfig0,
      ipconfig1,
      define_connection_info,
    ]
  }
}
