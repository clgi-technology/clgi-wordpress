variable "cloud_provider" {
  description = "Which cloud provider to deploy: aws, gcp, or azure"
  type        = string
  default     = "aws"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "my-vm"
}

variable "vm_size" {
  description = "Size of the VM instance"
  type        = string
  default     = "t2.micro"
}

variable "ssh_allowed_ip" {
  description = "IP allowed to SSH to the VM"
  type        = string
  default     = "0.0.0.0/0"
}

# AWS specific variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# GCP specific variables
variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "gcp_project" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_credentials" {
  description = "Path to GCP credentials JSON file"
  type        = string
  default     = ""
}

# Azure specific variables
variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = ""
}

variable "azure_client_id" {
  description = "Azure client ID (service principal)"
  type        = string
  default     = ""
}

variable "azure_client_secret" {
  description = "Azure client secret (service principal)"
  type        = string
  default     = ""
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
  default     = ""
}
