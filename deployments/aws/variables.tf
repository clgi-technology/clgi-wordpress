#############################
# 🌐 Common Variables
#############################

variable "cloud_provider" {
  type        = string
  description = "Cloud provider to deploy to (aws, gcp, azure)"
}

variable "deployment_mode" {
  type        = string
  description = "Deployment mode: sandbox = Django, production = WordPress"
}

variable "auto_delete_after_24h" {
  type        = bool
  description = "If true, mark resources for deletion after 24h"
  default     = false
}

variable "region" {
  type        = string
  description = "Region to deploy the VM in"
}

variable "vm_name" {
  type        = string
  description = "Name of the VM to deploy"
}

variable "vm_size" {
  type        = string
  description = "Size of the VM (machine type varies per cloud)"
}

variable "ssh_allowed_ip" {
  type        = string
  description = "CIDR range allowed to access VM via SSH"
}

#############################
# 🔐 SSH & Access
#############################

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key to install on the VM"
  sensitive   = true
}

variable "ssh_private_key" {
  type        = string
  description = "Private SSH key used for provisioning"
  sensitive   = true
  default     = ""
}

variable "ssh_password" {
  type        = string
  description = "Optional password for SSH login"
  sensitive   = true
  default     = ""
}

#############################
# ☁️ AWS-Specific Variables
#############################

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key ID"
  sensitive   = true
  default     = ""
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Access Key"
  sensitive   = true
  default     = ""
}

variable "aws_session_token" {
  type        = string
  description = "AWS Session Token (for STS)"
  sensitive   = true
  default     = ""
}

#############################
# ☁️ GCP-Specific Variables
#############################

variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
  default     = ""
}

variable "gcp_credentials" {
  type        = string
  description = "GCP Service Account JSON (optional, if not via env)"
  sensitive   = true
  default     = ""
}

#############################
# ☁️ Azure-Specific Variables
#############################

variable "azure_client_id" {
  type        = string
  description = "Azure Client ID"
  sensitive   = true
  default     = ""
}

variable "azure_client_secret" {
  type        = string
  description = "Azure Client Secret"
  sensitive   = true
  default     = ""
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID"
  sensitive   = true
  default     = ""
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant ID"
  sensitive   = true
  default     = ""
}
