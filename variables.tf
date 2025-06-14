variable "vm_name" {}
variable "vm_size" {}
variable "region" {}

variable "ssh_allowed_ip" {}

variable "ssh_password" {
  default = null
}

variable "setup_demo_clone" {
  default = false
}

variable "clone_target_url" {
  default = null
}

variable "deployment_mode" {
  default = "sandbox"
}

variable "auto_delete_after_24h" {
  default = false
}
