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
  count       = var.enabled ? 1 : 0
  name        = "${var.vm_name}-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux" {
  count       = var.enabled ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "vm" {
  count                       = var.enabled ? 1 : 0
  ami                         = data.aws_ami.amazon_linux[0].id
  instance_type               = var.vm_size
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = aws_key_pair.deployer[0].key_name
  vpc_security_group_ids      = [aws_security_group.ssh[0].id]
  associate_public_ip_address = true
  user_data                   = var.user_data
  vpc_security_group_ids      = var.security_group_id != "" ? [var.security_group_id] : [aws_security_group.ssh[0].id]


  tags = {
    Name = var.vm_name
  }
}
