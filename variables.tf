# root/variables.tf

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
}

variable "region" {
  description = "Region for deployment"
  type        = string
}

variable "ssh_allowed_ip" {
  description = "CIDR block for allowed SSH access"
  type        = string
}

variable "ssh_password" {
  description = "Optional SSH password (used in Azure)"
  type        = string
  default     = null
}

variable "setup_demo_clone" {
  description = "Whether to clone a demo site"
  type        = bool
  default     = false
}

variable "clone_target_url" {
  description = "URL of the site to clone"
  type        = string
  default     = null
}

variable "deployment_mode" {
  description = "Deployment mode: sandbox or production"
  type        = string
  default     = "sandbox"
}

variable "auto_delete_after_24h" {
  description = "Auto-delete environment after 24 hours?"
  type        = bool
  default     = false
}
