provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.region
  map_public_ip_on_launch = true
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

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
}

resource "aws_key_pair" "generated_key" {
  key_name   = "generated-key"
  public_key = tls_public_key.generated_key.public_key_openssh
}

resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_instance" "vm" {
  ami           = "ami-0c55b159cbfafe1f0" # Replace with a valid Ubuntu AMI ID
  instance_type = var.vm_size
  subnet_id     = aws_subnet.main.id
  key_name      = aws_key_pair.generated_key.key_name
  security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = var.vm_name
  }

  lifecycle {
    prevent_destroy = var.deployment_mode == "production" ? true : false
  }
}

resource "null_resource" "auto_delete" {
  count = var.deployment_mode == "sandbox" && var.auto_delete == "yes" ? 1 : 0

  provisioner "local-exec" {
    command = "sleep 86400 && terraform destroy -auto-approve"
  }
}
