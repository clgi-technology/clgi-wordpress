# Required Azure credentials
variable "azure_client_id" {}
variable "azure_secret" {}
variable "azure_tenant_id" {}
variable "azure_subscription_id" {}

# Basic VM configuration
variable "region" {}
variable "vm_name" {}
variable "vm_size" {}

# Optional customization and flags
variable "ssh_ip_address" {
  description = "Optional IP address to allow SSH access from"
  type        = string
  default     = null
}

variable "ssh_password" {
  description = "Optional SSH password"
  type        = string
  default     = null
}

variable "ssh_allowed_ip" {
  description = "The IP address or CIDR block allowed to SSH into the VM"
  type        = string
}

variable "setup_demo_clone" {
  description = "If true, clone a demo repo into the VM"
  type        = bool
  default     = false
}

variable "clone_target_url" {
  description = "Git URL to clone into the VM"
  type        = string
  default     = null
}

variable "deployment_mode" {
  description = "Deployment mode (e.g. sandbox, production)"
  type        = string
  default     = "sandbox"
}

variable "auto_delete_after_24h" {
  description = "Automatically delete the VM after 24 hours"
  type        = bool
  default     = false
}
