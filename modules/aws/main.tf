# modules/aws/main.tf

variable "enabled" {
  type    = bool
  default = true
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
}

variable "region" {
  description = "Region for AWS resources"
  type        = string
}

variable "ssh_allowed_ip" {
  description = "CIDR block for allowed SSH access"
  type        = string
}

variable "deployment_mode" {
  description = "Deployment mode (sandbox or production)"
  type        = string
}

variable "setup_demo_clone" {
  description = "Whether to clone a demo site"
  type        = bool
  default     = false
}

variable "clone_target_url" {
  description = "URL of the demo site to clone"
  type        = string
  default     = ""
}

variable "auto_delete_after_24h" {
  description = "Whether to auto-destroy the infra after 24h"
  type        = bool
  default     = false
}

variable "ssh_password" {
  description = "Optional password for SSH access"
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "Public SSH key to inject into AWS EC2"
  type        = string
}

variable "user_data" {
  description = "Startup script to configure the VM"
  type        = string
  default     = ""
}

resource "tls_private_key" "key" {
  count     = var.enabled ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  count      = var.enabled ? 1 : 0
  key_name   = "${var.vm_name}-key"
  public_key = var.ssh_public_key
}

data "aws_availability_zones" "available" {
  count = var.enabled ? 1 : 0
}

resource "aws_vpc" "main" {
  count      = var.enabled ? 1 : 0
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.vm_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = var.enabled ? 1 : 0
  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available[0].names[0]

  tags = {
    Name = "${var.vm_name}-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  count  = var.enabled ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  tags = {
    Name = "${var.vm_name}-igw"
  }
}

resource "aws_route_table" "rt" {
  count  = var.enabled ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  tags = {
    Name = "${var.vm_name}-rt"
  }
}

resource "aws_route" "default" {
  count                  = var.enabled ? 1 : 0
  route_table_id         = aws_route_table.rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_route_table_association" "assoc" {
  count          = var.enabled ? 1 : 0
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.rt[0].id
}

resource "aws_security_group" "ssh" {
  count       = var.enabled ?
