# modules/aws/variables.tf
variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
}

variable "region" {
  description = "Region for AWS resources"
  type        = string
}

variable "ssh_allowed_ip" {
  description = "CIDR block for allowed SSH access"
  type        = string
}

variable "deployment_mode" {
  description = "Deployment mode (sandbox or production)"
  type        = string
}

variable "setup_demo_clone" {
  description = "Whether to clone a demo site"
  type        = bool
  default     = false
}

variable "clone_target_url" {
  description = "URL of the demo site to clone"
  type        = string
  default     = ""
}

variable "auto_delete_after_24h" {
  description = "Whether to auto-destroy the infra after 24h"
  type        = bool
  default     = false
}

variable "ssh_password" {
  description = "Optional password for SSH access"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "Public SSH key to inject into AWS EC2"
  type        = string
}

variable "user_data" {
  description = "Rendered user data script to bootstrap the VM"
  type        = string
  default     = ""
}
