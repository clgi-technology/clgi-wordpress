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

provider "aws" {
  alias  = "aws"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  session_token = var.aws_session_token
  region  = var.region
}

provider "google" {
  alias   = "gcp"
  project = var.gcp_project
  region  = var.region
  credentials = file(var.gcp_key_file)
}

provider "azurerm" {
  alias   = "azure"
  client_id     = var.azure_client_id
  client_secret = var.azure_secret
  tenant_id     = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

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
