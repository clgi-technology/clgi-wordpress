# Root variables.tf

variable "cloud_provider" {
  description = "Cloud provider to use: aws, gcp, or azure"
  type        = string
  default     = "aws"
}

variable "deployment_mode" {
  description = "Deployment mode, e.g. sandbox or production"
  type        = string
  default     = "sandbox"
}

variable "setup_demo_clone" {
  description = "Whether to setup demo clone"
  type        = bool
  default     = false
}

variable "auto_delete_after_24h" {
  description = "Whether to auto delete resources after 24 hours"
  type        = bool
  default     = false
}

variable "vm_name" {
  description = "VM instance name"
  type        = string
}

variable "vm_size" {
  description = "VM instance size/type"
  type        = string
}

# AWS variables
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key content"
  type        = string
  sensitive   = true
}

variable "ssh_allowed_ip" {
  description = "IP CIDR allowed to SSH"
  type        = string
}

variable "ssh_password" {
  description = "SSH password"
  type        = string
  default     = null
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  default     = null
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  default     = null
}

variable "aws_session_token" {
  description = "AWS session token (optional)"
  type        = string
  default     = null
}

# GCP variables
variable "gcp_project" {
  description = "GCP project ID"
  type        = string
  default     = null
}

# GCP credentials and location
variable "gcp_key_file" {
  description = "Path to GCP service account key JSON"
  type        = string
}

variable "gcp_credentials" {
  description = "Path to GCP credentials JSON"
  type        = string
  default     = null
}
variable "ssh_public_key_path" {
  description = "Path to SSH public key for GCP instance access"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = null
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default     = null
}

# Azure variables
variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
  default     = null
}

variable "azure_secret" {
  description = "Azure Secret"
  type        = string
  default     = null
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  default     = null
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = null
}

variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = null
}

# Optional secrets
variable "clone_target_url" {
  description = "Clone URL for demo"
  type        = string
  default     = null
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = null
}

variable "smtp_password" {
  description = "SMTP password"
  type        = string
  default     = null
}
