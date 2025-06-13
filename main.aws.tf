provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

# VPC
resource "aws_vpc" "terraform" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.vm_name}-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "terraform" {
  vpc_id                  = aws_vpc.terraform.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = {
    Name = "${var.vm_name}-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform.id
  tags = {
    Name = "${var.vm_name}-igw"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terraform.id
  tags = {
    Name = "${var.vm_name}-public-rt"
  }
}

# Default route to Internet Gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate route table with public subnet
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.terraform.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group allowing SSH from your IP
resource "aws_security_group" "terraform" {
  name        = "${var.vm_name}-sg"
  description = "Allow SSH inbound from allowed IP"
  vpc_id      = aws_vpc.terraform.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vm_name}-sg"
  }
}

# Generate SSH key pair locally (you can skip this if you use your own)
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.generated_key.private_key_pem
  filename = "${var.vm_name}_private_key.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.vm_name}-key"
  public_key = tls_private_key.generated_key.public_key_openssh
}

# EC2 Instance
resource "aws_instance" "vm" {
  ami                         = "ami-0c94855ba95c71c99" # Amazon Linux 2 in us-west-2, adjust region accordingly
  instance_type               = var.vm_size
  subnet_id                   = aws_subnet.terraform.id
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.terraform.id]
  associate_public_ip_address = true

  tags = {
    Name = var.vm_name
  }
}

# Output the public IP
output "vm_ip" {
  description = "Public IP address of the VM"
  value       = aws_instance.vm.public_ip
  sensitive   = false
}
