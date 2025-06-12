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
  access_key = var.cloud_provider == "AWS" ? var.aws_access_key : null
  secret_key = var.cloud_provider == "AWS" ? var.aws_secret_key : null
  token      = var.cloud_provider == "AWS" ? var.aws_session_token : null
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

# Your other resource definitions (e.g., VPC, subnet, instance) go here...


# AWS VPC (only create if vpc_id is not provided)
resource "aws_vpc" "default" {
  count             = var.vpc_id == "" ? 1 : 0  # Create a new VPC if vpc_id is empty
  cidr_block        = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "default-vpc"
  }
}

resource "aws_subnet" "default" {
  count = var.vpc_id == "" ? 1 : 0  # Only create subnet if VPC is created

  vpc_id = aws_vpc.default[count.index].id  # Reference the VPC using count.index
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "default-subnet"
  }
}

# Generate a new SSH private key (you can adjust the algorithm and size)
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generate the public key associated with the private key (use data instead of resource)
data "tls_public_key" "generated_key" {
  depends_on = [tls_private_key.generated_key]  # Ensure the private key is generated before creating the public key

  private_key_pem = tls_private_key.generated_key.private_key_pem
}

# AWS Key Pair Resource (using the generated public key)
resource "aws_key_pair" "key_pair" {
  count    = var.use_existing_key_pair ? 0 : 1
  key_name = "generated-key"
  
  # Corrected to use public_key_pem instead of public_key
  public_key = data.tls_public_key.generated_key.public_key_pem
}


resource "aws_security_group" "default" {
  count = var.vpc_id == "" ? 1 : 0  # Only create the security group if VPC is created

  vpc_id = var.vpc_id != "" ? var.vpc_id : aws_vpc.default[count.index].id  # Use count.index to reference VPC

  name   = "default-sg"
  description = "Default security group"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ip_address]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_instance" "vm" {
  count = var.cloud_provider == "AWS" ? 1 : 0
  ami   = data.aws_ami.latest_ubuntu.id
  instance_type = var.vm_size
  key_name = var.use_existing_key_pair ? var.existing_key_pair_name : aws_key_pair.key_pair[0].key_name
  vpc_security_group_ids = [aws_security_group.default[count.index].id]  # Accessing SG with count.index

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


# AWS AMI lookup for Ubuntu 20.04 (latest)
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
    var.cloud_provider == "AWS"   ? aws_instance.vm[0].public_ip :
    # var.cloud_provider == "GCP"   ? google_compute_instance.vm[0].network_interface[0].access_config[0].nat_ip :
    # var.cloud_provider == "Azure" ? azurerm_public_ip.public_ip[0].ip_address :
    null
  )
  description = "Public IP of the deployed instance"
}

# OUTPUT: Private key if generated
resource "local_file" "private_key" {
  count           = var.use_existing_key_pair ? 0 : 1
  filename        = "${path.module}/generated-key.pem"
  content         = tls_private_key.generated_key.private_key_pem
  file_permission = "0600"
}
