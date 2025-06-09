terraform {

  required_providers {

    aws = {

      source  = "hashicorp/aws"

      version = "~> 5.0"

    }

  }

}



variable "aws_access_key" {

  description = "AWS Access Key ID"

  type        = string

  sensitive   = true

}



variable "aws_secret_key" {

  description = "AWS Secret Access Key"

  type        = string

  sensitive   = true

}



variable "ssh_password" {

  description = "SSH password for the remote user"

  type        = string

  sensitive   = true

}



variable "region" {

  description = "AWS region"

  type        = string

}



variable "vm_size" {

  description = "VM size selection (t3.medium or t3.large)"

  type        = string



  validation {

    condition     = contains(["t3.medium", "t3.large"], var.vm_size)

    error_message = "❌ Invalid VM size! Choose 't3.medium' or 't3.large'."

  }

}



variable "vm_name" {

  description = "Name of the VM"

  type        = string

}



provider "aws" {

  region     = var.region

  access_key = var.aws_access_key

  secret_key = var.aws_secret_key

}



resource "aws_instance" "main" {

  ami           = "ami-0abcdef1234567890"

  instance_type = var.vm_size

  key_name      = "wordpress-key" # Optional



  user_data = <<-EOF

              #!/bin/bash

              echo 'ubuntu:${var.ssh_password}' | chpasswd

              sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

              systemctl restart sshd

              EOF



  tags = {

    Name = var.vm_name

  }

}



resource "null_resource" "wordpress_setup" {

  provisioner "remote-exec" {

    inline = [

      "echo \"🔄 Installing WordPress...\" | tee -a /home/ubuntu/wp-setup.log",

      "sudo apt update && sudo apt install -y apache2 php mysql-server",

      "wget https://wordpress.org/latest.tar.gz",

      "tar -xvf latest.tar.gz",

      "sudo mv wordpress /var/www/html/",

      "echo \"✅ WordPress Installed!\" | tee -a /home/ubuntu/wp-setup.log"

    ]

  }



  connection {

    type     = "ssh"

    host     = aws_instance.main.public_ip

    user     = "ubuntu"

    password = var.ssh_password

    timeout  = "2m"

  }

}



resource "null_resource" "wordpress_health_check" {

  depends_on = [null_resource.wordpress_setup]



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

      "echo \"[$(date)] ❌ WordPress failed health check!\" | tee -a /home/ubuntu/wordpress-setup.log"

    ]

  }



  connection {

    type     = "ssh"

    host     = aws_instance.main.public_ip

    user     = "ubuntu"

    password = var.ssh_password

    timeout  = "2m"

  }

}



output "vm_ip" {

  value       = aws_instance.main.public_ip

  description = "Public IP of the deployed instance"

}



output "wp_admin_password" {

  value       = "Generated password for WordPress Admin"

  description = "WordPress Admin Password"

  sensitive   = true

}