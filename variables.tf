# Cloud Provider Selection
variable "cloud_provider" {
  description = "Cloud provider for deployment (AWS, GCP, Azure)"
  type        = string
}

# AWS Credentials
variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "aws_session_token" {
  description = "AWS Session Token (optional, for temporary credentials)"
  type        = string
  sensitive   = true
  default     = ""
}

# GCP Credentials
variable "gcp_key_file" {
  description = "GCP Service Account Key JSON (as string)"
  type        = string
  sensitive   = true
}

variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}

# Azure Credentials
variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
  sensitive   = true
}

variable "azure_secret" {
  description = "Azure Client Secret"
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

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

# SSH and Key Management
variable "ssh_password" {
  description = "SSH password for the 'ubuntu' user"
  type        = string
  sensitive   = true
}

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

variable "vpc_id" {
  description = "VPC ID to associate with resources (used in security group module)"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Name of the project to prefix resources"
  type        = string
  default     = "my-project"  # optional default or remove if you want to provide explicitly
}

variable "ssh_ip_address" {
  description = "Your public IP address/CIDR to allow SSH (e.g., 203.0.113.0/32)"
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
