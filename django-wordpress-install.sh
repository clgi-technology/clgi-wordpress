#!/bin/bash

echo "🚀 Beginning VM Setup for Deployment Mode: $DEPLOYMENT_MODE"

# Update system packages
apt update && apt upgrade -y

if [ "$DEPLOYMENT_MODE" = "production" ]; then
    echo "🟢 Installing WordPress..."
    apt install -y apache2 mysql-server php php-mysql
    systemctl enable apache2
    systemctl enable mysql

    # Download and install WordPress
    wget https://wordpress.org/latest.tar.gz
    tar -xvzf latest.tar.gz -C /var/www/html/
    chown -R www-data:www-data /var/www/html/

    # Create WordPress database
    mysql -e "CREATE DATABASE wordpress_db;"
    mysql -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost' IDENTIFIED BY 'securepassword';"
    mysql -e "FLUSH PRIVILEGES;"

    echo "✅ WordPress Installed Successfully!"
elif [ "$DEPLOYMENT_MODE" = "sandbox" ]; then
    echo "🟠 Installing Django..."
    apt install -y python3-pip python3-venv
	python3 -m venv /opt/django-env
	source /opt/django-env/bin/activate
	pip install django
	django-admin startproject mysite /var/www/html/
