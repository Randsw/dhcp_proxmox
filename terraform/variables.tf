variable "region" {
  description = "Equal to Proxmox cluster name"
  type        = string
  default     = "pve"
}

variable "pool" {
  description = "Resource pool in Proxmox"
  type        = string
  default     = "prod"
}

variable "proxmox_host" {
  description = "Proxmox host"
  type        = string
  default     = "192.168.1.1"
}

variable "proxmox_image" {
  description = "Proxmox source image name"
  type        = string
  default     = "talos"
}

variable "proxmox_storage" {
  description = "Proxmox storage name"
  type        = string
}

variable "proxmox_token_id" {
  description = "Proxmox token id"
  type        = string
}

variable "proxmox_token_secret" {
  description = "Proxmox token secret"
  type        = string
}

variable "cores" {
  description = "Number of cores attached to VM"
  type = number
}

variable "ram" {
  description = "Value of RAM memory in VM"
  type = number
}

variable "disk_size" {
  description = "VM volume size"
  type = string
}

variable "vm_user" {
  description = "VM user name"
  type = string
  default = "ubuntu"
}

variable "target_node_name" {
  description = "Proxmox node name for CP"
  type        = string
}

variable "gateway" {
  type    = string
  default = "10.1.1.1"
}

variable "dhcp_server_ip" {
  description = "Dns server ip address"
  type = string
}

variable "dhcp_vm_template" {
  description = "Dns server VM template"
  type = string
}

variable "dhcp_vmid" {
  description = "VM ID for DNS server"
  type = string
  default = "201"
}