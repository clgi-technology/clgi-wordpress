resource
"aws_security_group" "ssh_sg" {
    name        = "ssh-security-group"
    description = "Allow SSH access from a given IP"
    vpc_id      = var.vpc_id  # This assumes a VPC ID is passed in

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_ip_address]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "SSHAccessSG"
    }
  }