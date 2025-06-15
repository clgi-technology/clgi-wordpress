variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "aws_session_token" {
  description = "AWS session token"
  type        = string
  default     = null
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_size" {
  description = "Instance type"
  type        = string
}

variable "ssh_allowed_ip" {
  description = "CIDR block allowed to SSH"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key contents"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = null
}

variable "ssh_password" {
  description = "Password used for SSH (if applicable)"
  type        = string
  default     = null
}

variable "deployment_mode" {
  description = "App to deploy: 'sandbox' or 'production'"
  type        = string
}

variable "setup_demo_clone" {
  description = "Whether to clone a demo site"
  type        = bool
  default     = false
}

variable "clone_target_url" {
  description = "URL to clone site from"
  type        = string
  default     = ""
}

variable "auto_delete_after_24h" {
  description = "Whether to automatically delete VM after 24h"
  type        = bool
  default     = false
}
