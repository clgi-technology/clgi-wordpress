terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Variables for cloud provider selection (Now references GitHub Secrets)
variable "cloud_provider" {
  description = "The cloud provider to use (aws, gcp, azure)"
  type        = string
  default     = "${var.TF_CLOUD_PROVIDER}"
}

variable "vm_name" {
  description = "The name of the VM"
  type        = string
  default     = "${var.TF_VM_NAME}"
}

variable "vm_size" {
  description = "The size of the VM"
  type        = string
  default     = "${var.TF_VM_SIZE}"
}

variable "region" {
  description = "The region to deploy the VM"
  type        = string
  default     = "${var.TF_REGION}"
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  default     = "${var.GH_TOKEN}"
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "${var.GH_REPO}"
}

variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
  default     = "${var.TF_GCP_PROJECT}"
}

variable "gcp_credentials_path" {
  description = "Path to GCP service account JSON"
  type        = string
  default     = "${var.TF_GCP_CREDENTIALS_PATH}"
}

# Providers setup (Now supports Multi-Cloud)
provider "aws" {
  region = var.region
}

provider "azurerm" {
  features {}
}

provider "google" {
  project     = var.gcp_project
  region      = var.region
  credentials = file(var.gcp_credentials_path)
}

# Generate a new SSH key per deployment
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/id_rsa"
}

resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "${path.module}/id_rsa.pub"
}

# Generate a secure WordPress admin password
resource "random_password" "wp_admin_password" {
  length  = 16
  special = true
}

# Deploy an AWS EC2 Instance (Example)
resource "aws_instance" "main" {
  ami           = "ami-0abcdef1234567890"  # Example AMI (change per region)
  instance_type = var.vm_size
  key_name      = tls_private_key.ssh_key.id
  tags = {
    Name = var.vm_name
  }
}

output "vm_ip" {
  value       = aws_instance.main.public_ip
  description = "Public IP of the deployed instance"
}

output "wp_admin_password" {
  value       = random_password.wp_admin_password.result
  description = "Generated WordPress Admin Password"
  sensitive   = true
}