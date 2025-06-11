# Cloud Provider Selection
variable "cloud_provider" {
  description = "Cloud provider for deployment (AWS/GCP/Azure)"
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
  description = "AWS Session Token (for temporary credentials)"
  type        = string
  sensitive   = true
}

# Google Cloud Credentials
variable "gcp_key_file" {
  description = "GCP Key File JSON (as a string)"
  type        = string
  sensitive   = true
}

# Azure Credentials
variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
  sensitive   = true
}

variable "azure_secret" {
  description = "Azure Secret Key"
  type        = string
  sensitive   = true
}

# VM Deployment Mode
variable "deployment_mode" {
  description = "Deployment mode: sandbox (Django) or production (WordPress)"
  type        = string
  default     = "sandbox"
}

# VM Configuration
variable "region" {
  description = "Cloud region (e.g., us-west-2 for AWS, us-central1 for GCP, eastus for Azure)"
  type        = string
}

variable "vm_size" {
  description = "VM size (e.g., t3.medium for AWS, e2-medium for GCP, Standard_B1s for Azure)"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "ssh_password" {
  description = "SSH password for the remote user"
  type        = string
  sensitive   = true
}

# Optional: Use existing infrastructure
variable "use_existing_key_pair" {
  description = "Use an existing key pair? (true/false)"
  type        = bool
  default     = false
}

variable "existing_key_pair_name" {
  description = "Name of existing key pair (if applicable)"
  type        = string
  default     = ""
}

variable "use_existing_vpc" {
  description = "Use an existing VPC? (true/false)"
  type        = bool
  default     = false
}

variable "existing_vpc_id" {
  description = "Existing VPC ID (if applicable)"
  type        = string
  default     = ""
}

# Optional: CLGI.org clone toggle
variable "setup_demo_clone" {
  description = "Deploy a demo site with clgi.org styling? (true/false)"
  type        = bool
  default     = false
}
