#!/bin/bash

echo "🚀 Beginning VM Setup for Deployment Mode: $DEPLOYMENT_MODE"

# Update system packages
apt update && apt upgrade -y

if [ "$DEPLOYMENT_MODE" = "production" ]; then
    echo "🟢 Installing WordPress..."
    apt install -y apache2 mysql-server php php-mysql libapache2-mod-php unzip

    systemctl enable apache2
    systemctl enable mysql
    systemctl start apache2
    systemctl start mysql

    # Download and install WordPress if not already installed
    if [ ! -d /var/www/html/wordpress ]; then
        wget https://wordpress.org/latest.tar.gz
        tar -xvzf latest.tar.gz -C /var/www/html/
        chown -R www-data:www-data /var/www/html/wordpress
    else
        echo "WordPress already installed."
    fi

    # Create WordPress database and user if not exists
    DB_EXISTS=$(mysql -uroot -e "SHOW DATABASES LIKE 'wordpress_db';" | grep wordpress_db || true)
    if [ -z "$DB_EXISTS" ]; then
        mysql -uroot -e "CREATE DATABASE wordpress_db;"
        mysql -uroot -e "CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'securepassword';"
        mysql -uroot -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';"
        mysql -uroot -e "FLUSH PRIVILEGES;"
        echo "WordPress database and user created."
    else
        echo "WordPress database already exists."
    fi

    echo "✅ WordPress Installed Successfully!"

elif [ "$DEPLOYMENT_MODE" = "sandbox" ]; then
    echo "🟠 Installing Django stack for sandbox..."

    apt install -y python3-pip python3-venv

    # Setup python venv for Django
    python3 -m venv /opt/django-env
    source /opt/django-env/bin/activate

    # Install Django inside the venv
    pip install django

    # Create Django project if not exists
    if [ ! -d /var/www/html/mysite ]; then
      django-admin startproject mysite /var/www/html/
    else
      echo "Django project already exists."
    fi

    # Setup Apache to serve WordPress directory (for potential coexistence)
    cat <<EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/wordpress
    <Directory /var/www/html/wordpress>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

    a2ensite wordpress
    a2enmod rewrite
    systemctl reload apache2

fi
