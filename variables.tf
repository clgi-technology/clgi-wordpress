# Cloud Provider Selection
variable "cloud_provider" {
  description = "The cloud provider to use (AWS, GCP, Azure)"
  type        = string
  default     = "AWS"
}

# Azure Variables
variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "azure_secret" {
  description = "Azure Client Secret"
  type        = string
}

# GCP Variables
variable "gcp_project" {
  description = "The GCP project ID"
  type        = string
}

variable "gcp_key_file" {
  description = "Path to the GCP service account key file"
  type        = string
}

# AWS Credentials (optional if using IAM roles/environment vars)
variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "aws_session_token" {
  description = "AWS Session Token (optional)"
  type        = string
  default     = ""
}

# Networking and Project
variable "region" {
  description = "Cloud region (e.g., us-west-2, us-central1, eastus)"
  type        = string
}

variable "ssh_ip_address" {
  description = "The SSH IP address (CIDR block)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_password" {
  description = "Password for SSH access"
  type        = string
  sensitive   = true
}

# VM Configuration
variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_size" {
  description = "VM size (AWS: t3.medium, GCP: e2-medium, Azure: Standard_B1s)"
  type        = string
}

# Deployment Options
variable "deployment_mode" {
  description = "Deployment mode: 'sandbox' for Django or 'production' for WordPress"
  type        = string
  default     = "sandbox"
}

variable "auto_delete_after_24h" {
  description = "Auto-delete resources after 24h (only applies to sandbox mode)"
  type        = bool
  default     = false
}

variable "setup_demo_clone" {
  description = "If true, clones a static site instead of using Django/WordPress"
  type        = bool
  default     = false
}

variable "clone_target_url" {
  description = "URL of the website to clone if setup_demo_clone is true"
  type        = string
  default     = ""
}

# Optional Secrets
variable "db_password" {
  description = "Database password (used for WordPress or Django if applicable)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "smtp_password" {
  description = "SMTP password (if sending email is configured)"
  type        = string
  sensitive   = true
  default     = ""
}
