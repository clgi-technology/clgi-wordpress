variable "cloud_provider" {
  description = "Cloud provider to use (AWS, GCP, or Azure)"
  type        = string
}

variable "deployment_mode" {
  description = "Deployment mode (sandbox or production)"
  type        = string
}

variable "setup_demo_clone" {
  description = "Whether to setup demo clone"
  type        = bool
}

variable "vm_name" {
  description = "The name of the VM"
  type        = string
}

variable "vm_size" {
  description = "The size of the VM"
  type        = string
}

variable "region" {
  description = "The cloud region"
  type        = string
}

variable "ssh_ip_address" {
  description = "The allowed IP address for SSH access"
  type        = string
}

variable "clone_target_url" {
  description = "The URL for the clone target (if applicable)"
  type        = string
  default     = ""
}

variable "ssh_password" {
  description = "SSH password for authentication"
  type        = string
}

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
  default     = ""
}

variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_key_file" {
  description = "Path to GCP key file"
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

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "smtp_password" {
  description = "SMTP password"
  type        = string
}
