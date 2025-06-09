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

variable "cloud_provider" {
  description = "The cloud provider to use (aws, gcp, azure)"
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

variable "region" {
  description = "The region to deploy the VM"
  type        = string
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_credentials_path" {
  description = "Path to GCP service account JSON"
  type        = string
}

provider "aws" {
  region = var.region
}

provider "azurerm" {
  features {}
}

provider "google" {
  project     = var.gcp_project
  region      = var.region
  credentials = file("${path.module}/gcp_credentials.json")
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "wordpress-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_instance" "main" {
  ami           = "ami-0abcdef1234567890"
  instance_type = var.vm_size
  key_name      = aws_key_pair.deployer.key_name
  tags = {
    Name = var.vm_name
  }
}

resource "null_resource" "wordpress_health_check" {
  provisioner "remote-exec" {
    inline = [
      "echo \"[$(date)] 🔍 Starting health check for WordPress...\" | tee -a /home/ubuntu/wordpress-setup.log",
      "attempts=0",
      "max_attempts=5",
      "while [ $attempts -lt $max_attempts ]; do",
      "  http_code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost)",
      "  echo \"[$(date)] HTTP Response: $http_code\" | tee -a /home/ubuntu/wordpress-setup.log",
      "  if [ $http_code -eq 200 ]; then",
      "    echo \"[$(date)] ✅ WordPress is up and running!\" | tee -a /home/ubuntu/wordpress-setup.log",
      "    exit 0",
      "  else",
      "    echo \"[$(date)] ⚠️ WordPress not ready (HTTP $http_code), retrying...\" | tee -a /home/ubuntu/wordpress-setup.log",
      "    attempts=$((attempts+1))",
      "    sleep 5",
      "  fi",
      "done",
      "echo \"[$(date)] ❌ WordPress failed health check!\" | tee -a /home/ubuntu/wordpress-setup.log",
      "exit 1"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.main.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
  }
}

resource "null_resource" "rollback_on_failure" {
  depends_on = [null_resource.wordpress_health_check]

  provisioner "local-exec" {
    command = "terraform destroy -auto-approve && terraform apply -auto-approve"
  }

  triggers = {
    force_redeploy = timestamp(),
    health_check_failed = fileexists("/home/ubuntu/wordpress-setup.log") && grep -q "❌" /home/ubuntu/wordpress-setup.log
  }
}

output "vm_ip" {
  value       = aws_instance.main.public_ip
  description = "Public IP of the deployed instance"
}

output "wordpress_health_status" {
  value       = "Check logs at /home/ubuntu/wordpress-setup.log for health check results"
  description = "Indicates whether WordPress is running"
}