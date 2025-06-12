# AWS related variables
variable "aws_access_key" {
  description = "The AWS access key for authentication"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "The AWS secret key for authentication"
  type        = string
  sensitive   = true
}

variable "aws_session_token" {
  description = "The AWS session token (if using temporary credentials)"
  type        = string
  sensitive   = true
}

# GCP related variables
variable "gcp_key_file" {
  description = "Path to the Google Cloud service account JSON key file"
  type        = string
  sensitive   = true
}

variable "gcp_project" {
  description = "The project ID in GCP"
  type        = string
}

# Azure related variables
variable "azure_client_id" {
  description = "The Azure client ID (application ID)"
  type        = string
  sensitive   = true
}

variable "azure_secret" {
  description = "The Azure client secret (application secret)"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}

variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

# General configuration variables
variable "region" {
  description = "The region to deploy resources"
  type        = string
}

variable "vm_name" {
  description = "The name of the VM"
  type        = string
}

variable "vm_size" {
  description = "The size of the VM"
  type        = string
}

variable "deployment_mode" {
  description = "Deployment mode for resources"
  type        = string
}

variable "ssh_password" {
  description = "Password for SSH authentication"
  type        = string
}

variable "setup_demo_clone" {
  description = "Whether to set up a demo clone"
  type        = bool
}

variable "clone_target_url" {
  description = "URL for cloning demo application"
  type        = string
}

variable "use_existing_key_pair" {
  description = "Flag to use an existing key pair for SSH"
  type        = bool
}

variable "existing_key_pair_name" {
  description = "The name of the existing SSH key pair"
  type        = string
}

variable "project_name" {
  description = "Name of the project to prefix resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "ssh_ip_address" {
  description = "CIDR block to allow SSH access (e.g. 203.0.113.0/32)"
  type        = string
}
