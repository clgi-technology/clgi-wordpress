terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    google = {
      source = "hashicorp/google"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  alias         = "aws"
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  session_token = var.aws_session_token
  region        = var.region
}

# GCP Provider Configuration
provider "google" {
  alias        = "gcp"
  project      = var.gcp_project
  region       = var.region
  credentials  = file(var.gcp_key_file)
}

# Azure Provider Configuration
provider "azurerm" {
  alias            = "azure"
  client_id        = var.azure_client_id
  client_secret    = var.azure_secret
  tenant_id        = var.azure_tenant_id
  subscription_id  = var.azure_subscription_id
}

# AWS Security Group Resource
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP, HTTPS, and SSH access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from allowed IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ip_address]
  }

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# Cloud Selection and Mode (from your `.tfvars`)
cloud_provider        = "AWS"            # Can be AWS, GCP, or Azure
deployment_mode       = "sandbox"        # sandbox = Django, production = WordPress
setup_demo_clone      = false            # true = static clone from URL, false = framework

# VM Configuration
vm_name               = "wordpress-server"
vm_size               = "t3.medium"
region                = "us-west-2"

# Networking
ssh_ip_address        = "203.0.113.45/32"  # Replace with your real IP

# Optional Clone Target
clone_target_url      = ""                # Only required if setup_demo_clone = true

# Secrets: Do NOT commit real values — use GitHub Secrets or environment variables!
ssh_password          = "YOUR_SECURE_SSH_PASSWORD"

# AWS Credentials (DO NOT COMMIT THESE — use GitHub Actions secrets or environment vars)
aws_access_key        = "REPLACE_WITH_ENV_VAR_OR_SECRET"
aws_secret_key        = "REPLACE_WITH_ENV_VAR_OR_SECRET"
aws_session_token     = "REPLACE_IF_NEEDED"

# GCP (Optional)
gcp_project           = "your-gcp-project-id"
gcp_key_file          = "your-gcp-key-file-path" # Path to GCP service account JSON key

# Azure Credentials (Optional)
azure_client_id       = "REPLACE_WITH_YOUR_AZURE_CLIENT_ID"
azure_secret          = "REPLACE_WITH_YOUR_AZURE_SECRET"
azure_tenant_id       = "REPLACE_WITH_YOUR_AZURE_TENANT_ID"
azure_subscription_id = "REPLACE_WITH_YOUR_AZURE_SUBSCRIPTION_ID"

# Optional DB/SMTP
db_password           = "example-db-password"
smtp_password         = "example-smtp-password"

