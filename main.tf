terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "ssh_private_key" {}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "main" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.medium"
  key_name      = "wordpress-key"
  tags = {
    Name = "CLGI-WordPress"
  }
}

resource "null_resource" "wordpress_setup" {
  provisioner "remote-exec" {
    inline = [
      "echo \"🔄 Installing WordPress & Plugins...\" | tee -a /home/ubuntu/wp-setup.log",
      "sudo apt update && sudo apt install -y apache2 php mysql-server",
      "wget https://wordpress.org/latest.tar.gz",
      "tar -xvf latest.tar.gz",
      "sudo mv wordpress /var/www/html/",

      # Clone CLGI website structure
      "wget -r -np -nH --cut-dirs=1 -P /var/www/html/clgi_clone https://www.clgi.org",
      "echo \"✅ CLGI Site Structure Copied!\" | tee -a /home/ubuntu/wp-setup.log",

      # Apply CLGI theme
      "wget -P /var/www/html/wp-content/themes/ https://www.clgi.org/wp-content/themes/clgi-theme.zip",
      "unzip /var/www/html/wp-content/themes/clgi-theme.zip -d /var/www/html/wp-content/themes/",
      "echo \"✅ CLGI Theme Installed!\" | tee -a /home/ubuntu/wp-setup.log",

      # Install essential WordPress plugins
      "wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/yoast-seo.zip",
      "wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/contact-form-7.zip",
      "wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/wp-super-cache.zip",
      "wget -P /var/www/html/wp-content/plugins/ https://downloads.wordpress.org/plugin/wordfence.zip",
      "unzip /var/www/html/wp-content/plugins/*.zip -d /var/www/html/wp-content/plugins/",
      "echo \"✅ WordPress Plugins Installed!\" | tee -a /home/ubuntu/wp-setup.log"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.main.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key)
  }
}

resource "null_resource" "wordpress_health_check" {
  depends_on = [null_resource.wordpress_setup]

  provisioner "remote-exec" {
    inline = [
      "echo \"🔍 Starting health check for WordPress...\" | tee -a /home/ubuntu/wp-setup.log",
      "attempts=0",
      "max_attempts=5",
      "while [ $attempts -lt $max_attempts ]; do",
      "  http_code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost)",
      "  if [ $http_code -eq 200 ]; then",
      "    echo \"✅ WordPress is up and running!\" | tee -a /home/ubuntu/wp-setup.log",
      "    exit 0",
      "  else",
      "    echo \"⚠️ WordPress not ready (HTTP $http_code), retrying...\" | tee -a /home/ubuntu/wp-setup.log",
      "    attempts=$((attempts+1))",
      "    sleep 5",
      "  fi",
      "done",
      "echo \"❌ WordPress failed health check! Running targeted rollback...\" | tee -a /home/ubuntu/wp-setup.log",
      "terraform destroy -target=aws_instance.main -auto-approve",
      "terraform apply -target=aws_instance.main -auto-approve"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.main.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key)
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