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

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "main" {
  ami           = "ami-0abcdef1234567890"
  instance_type = var.vm_size
  key_name      = "wordpress-key"
  tags = {
    Name = var.vm_name
  }
}

resource "null_resource" "wordpress_setup" {
  provisioner "remote-exec" {
    inline = [
      "export AWS_ACCESS_KEY_ID='${var.aws_access_key}'",
      "export AWS_SECRET_ACCESS_KEY='${var.aws_secret_key}'",
      "echo \"🔄 Installing WordPress...\" | tee -a /home/ubuntu/wp-setup.log",
      "sudo apt update && sudo apt install -y apache2 php mysql-server",
      "wget https://wordpress.org/latest.tar.gz",
      "tar -xvf latest.tar.gz",
      "sudo mv wordpress /var/www/html/",
      "echo \"✅ WordPress Installed!\" | tee -a /home/ubuntu/wp-setup.log"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.main.public_ip
    user        = "ubuntu"
    private_key = file("${path.module}/ssh-key.pem")
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

variable "environment" {
  description = "Deployment environment (prod or sandbox)"
  type        = string

  validation {
    condition     = contains(["prod", "sandbox"], var.environment)
    error_message = "❌ Invalid environment! Choose either 'prod' or 'sandbox'."
  }
}

variable "cloud_provider" {
  description = "The cloud provider to use (aws, gcp, azure)"
  type        = string

  validation {
    condition     = contains(["aws", "gcp", "azure"], var.cloud_provider)
    error_message = "❌ Invalid cloud provider! Choose 'aws', 'gcp', or 'azure'."
  }
}

variable "database_type" {
  description = "Database selection (mysql or postgresql)"
  type        = string

  validation {
    condition     = contains(["mysql", "postgresql"], var.database_type)
    error_message = "❌ Invalid database! Choose 'mysql' or 'postgresql'."
  }
}

variable "vm_size" {
  description = "VM size selection (t3.medium or t3.large)"
  type        = string

  validation {
    condition     = contains(["t3.medium", "t3.large"], var.vm_size)
    error_message = "❌ Invalid VM size! Choose 't3.medium' or 't3.large'."
  }
}

provider "aws" {
  region = var.region
  count  = var.cloud_provider == "aws" ? 1 : 0
}

provider "google" {
  project     = var.gcp_project
  region      = var.region
  credentials = file("${path.module}/gcp_credentials.json")
  count       = var.cloud_provider == "gcp" ? 1 : 0
}

provider "azurerm" {
  features {}
  count = var.cloud_provider == "azure" ? 1 : 0
}

resource "aws_instance" "main" {
  ami           = "ami-0abcdef1234567890"
  instance_type = var.vm_size
  key_name      = "wordpress-key"
  tags = {
    Name = var.vm_name
  }
}

resource "null_resource" "wordpress_setup" {
  provisioner "remote-exec" {
    inline = [
      "echo \"[$(date)] 🔄 Installing WordPress...\" | tee -a /home/ubuntu/wordpress-setup.log",
      "sudo apt update && sudo apt install -y apache2 php mysql-server",
      "wget https://wordpress.org/latest.tar.gz",
      "tar -xvf latest.tar.gz",
      "sudo mv wordpress /var/www/html/",
      "echo \"[$(date)] ✅ WordPress installed!\" | tee -a /home/ubuntu/wordpress-setup.log",
      
      "echo \"[$(date)] 🔄 Cloning CLGI Website...\" | tee -a /home/ubuntu/wordpress-setup.log",
      "wget -r -np -nH --cut-dirs=1 -P /var/www/html/clgi_clone https://www.clgi.org",
      "echo \"[$(date)] ✅ Site structure copied!\" | tee -a /home/ubuntu/wordpress-setup.log",
      
      "echo \"[$(date)] 🔄 Applying CLGI Theme...\" | tee -a /home/ubuntu/wordpress-setup.log",
      "wget -P /var/www/html/wp-content/themes/ https://www.clgi.org/wp-content/themes/clgi-theme.zip",
      "unzip /var/www/html/wp-content/themes/clgi-theme.zip -d /var/www/html/wp-content/themes/",
      "echo \"[$(date)] ✅ Theme installed!\" | tee -a /home/ubuntu/wordpress-setup.log"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.main.public_ip
    user        = "ubuntu"
    private_key = file("${path.module}/ssh-key.pem")
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
      "echo \"[$(date)] ❌ WordPress failed health check! Running rollback...\" | tee -a /home/ubuntu/wordpress-setup.log",
      "terraform destroy -auto-approve",
      "terraform apply -auto-approve"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.main.public_ip
    user        = "ubuntu"
    private_key = file("${path.module}/ssh-key.pem")
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