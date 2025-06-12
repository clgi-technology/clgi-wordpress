# Cloud Provider Selection
variable "cloud_provider" {
  description = "The cloud provider to use (AWS, GCP, Azure)"
  type        = string
  default     = "AWS"  # Default to AWS
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

# AWS Variables
variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "aws_session_token" {
  description = "AWS Session Token"
  type        = string
}

# Project and Network Variables
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "my-project"  # optional default or remove if you want to provide explicitly
}

variable "vpc_id" {
  description = "The AWS VPC ID"
  type        = string
}

# Networking and SSH
variable "ssh_ip_address" {
  description = "The SSH IP address (CIDR block)"
  type        = string
}

variable "ssh_password" {
  description = "Password for SSH access"
  type        = string
  sensitive   = true
}

# VM Configuration
variable "region" {
  description = "Cloud region (e.g., us-west-2, us-central1, eastus)"
  type        = string
}

variable "vm_size" {
  description = "VM size (AWS: t3.medium, GCP: e2-medium, Azure: Standard_B1s)"
  type        = string
}

variable "security_group_id" {
  type    = string
  default = ""  # or set a default for known SG
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

# Deployment Options
variable "deployment_mode" {
  description = "Deployment mode: 'sandbox' for Django or 'production' for WordPress"
  type        = string
  default     = "sandbox"
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

# Optional: Database / SMTP
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

# SSH and Key Management
variable "use_existing_key_pair" {
  description = "Use an existing key pair instead of generating a new one"
  type        = bool
  default     = false
}

variable "existing_key_pair_name" {
  description = "Name of the existing key pair (if applicable)"
  type        = string
  default     = ""
}

# VPC / Networking
variable "use_existing_vpc" {
  description = "Use an existing VPC"
  type        = bool
  default     = false
}

variable "existing_vpc_id" {
  description = "Existing VPC ID to use (if applicable)"
  type        = string
  default     = ""
}
