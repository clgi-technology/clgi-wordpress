# Terraform block with required providers and version constraint
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.3.0"
}

# AWS provider configuration
provider "aws" {
  alias  = "aws"
  region = var.region
}

# GCP provider configuration
provider "google" {
  alias       = "google"
  credentials = var.cloud_provider == "GCP" ? var.gcp_key_file : null
  project     = var.gcp_project
  region      = var.region
}

# Azure provider configuration
provider "azurerm" {
  alias           = "azurerm"
  features        = {}

  client_id       = var.cloud_provider == "Azure" ? var.azure_client_id : null
  client_secret   = var.cloud_provider == "Azure" ? var.azure_secret : null
  tenant_id       = var.cloud_provider == "Azure" ? var.azure_tenant_id : null
  subscription_id = var.cloud_provider == "Azure" ? var.azure_subscription_id : null
}

# AWS VPC (only create if vpc_id is not provided)
resource "aws_vpc" "terraform" {
  count                  = var.vpc_id == "" ? 1 : 0
  cidr_block             = "10.0.0.0/16"
  enable_dns_support     = true
  enable_dns_hostnames   = true

  tags = {
    Name = "terraform-vpc"
  }
}

# AWS Subnet
resource "aws_subnet" "terraform" {
  count = var.vpc_id == "" ? 1 : 0

  vpc_id                  = aws_vpc.terraform[count.index].id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-subnet"
  }
}

# TLS key generation
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "tls_public_key" "generated_key" {
  depends_on        = [tls_private_key.generated_key]
  private_key_pem   = tls_private_key.generated_key.private_key_pem
}

resource "aws_key_pair" "key_pair" {
  count      = var.use_existing_key_pair ? 0 : 1
  key_name   = "generated-key"
  public_key = data.tls_public_key.generated_key.public_key_openssh
}

# AWS Security Group
resource "aws_security_group" "terraform" {
  count  = var.vpc_id == "" ? 1 : 0
  vpc_id = var.vpc_id != "" ? var.vpc_id : aws_vpc.terraform[count.index].id

  name        = "terraform-sg"
  description = "Default security group"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ip_address]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "vm" {
  count         = var.cloud_provider == "AWS" ? 1 : 0
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = var.vm_size
  key_name      = var.use_existing_key_pair ? var.existing_key_pair_name : aws_key_pair.key_pair[0].key_name

  subnet_id = var.vpc_id == "" ? aws_subnet.terraform[0].id : var.subnet_id
  vpc_security_group_ids = var.vpc_id == "" ? [aws_security_group.terraform[0].id] : [var.security_group_id]

  user_data = templatefile("${path.module}/user_data.sh.tmpl", {
    deployment_mode   = var.deployment_mode,
    setup_demo_clone  = var.setup_demo_clone,
    ssh_password      = var.ssh_password,
    clone_target_url  = var.clone_target_url
  })

  tags = {
    Name = var.vm_name
  }

  provider = aws.aws
}

# AWS AMI lookup
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  provider = aws.aws
}

# OUTPUT: Public IP
output "vm_ip" {
  value = (
    var.cloud_provider == "AWS" ? aws_instance.vm[0].public_ip : null
  )
  description = "Public IP of the deployed instance"
}

# OUTPUT: Private key file
resource "local_file" "private_key" {
  count           = var.use_existing_key_pair ? 0 : 1
  filename        = "${path.module}/generated-key.pem"
  content         = tls_private_key.generated_key.private_key_pem
  file_permission = "0600"
}
