variable "gcp_project" {}
variable "gcp_credentials" {}
variable "vm_name" {}
variable "vm_size" {}
variable "region" {}
variable "zone" {}
variable "ssh_allowed_ip" {}

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
