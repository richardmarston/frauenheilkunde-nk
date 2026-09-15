variable "hcloud_token" {
  description = "Hetzner Cloud API token (Console -> project -> Security -> API Tokens)"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Primary domain served by this VM"
  type        = string
  default     = "frauenheilkunde-nk.at"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key installed on the VM"
  type        = string
  default     = "./.ssh/frauenheilkunde-nk.pub"
}

variable "server_type" {
  description = "Hetzner Cloud server type"
  type        = string
  default     = "cx23"
}

variable "image" {
  description = "OS image"
  type        = string
  default     = "debian-12"
}

variable "location" {
  description = "Hetzner Cloud datacenter"
  type        = string
  default     = "fsn1"
}
