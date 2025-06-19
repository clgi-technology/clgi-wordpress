#!/bin/bash

set -e

echo "🚀 Starting Django installation on Amazon Linux 2..."

# Update system and install dependencies
yum update -y
yum install -y python3 python3-pip postgresql postgresql-server postgresql-devel gcc gcc-c++ python3-devel

# Initialize and start PostgreSQL service if not already initialized
if [ ! -d /var/lib/pgsql/data ]; then
  echo "Initializing PostgreSQL database..."
  postgresql-setup initdb
fi

systemctl enable postgresql
systemctl start postgresql

# Create project directory
mkdir -p /opt/django-app
cd /opt/django-app

# Set up virtual environment
python3 -m venv venv
source venv/bin/activate

# Create requirements.txt
cat <<EOF > requirements.txt
django==4.2.2
requests==2.31.0
beautifulsoup4==4.12.2
gunicorn==20.1.0
psycopg2-binary==2.9.9
django-debug-toolbar
python-dotenv
EOF

# Upgrade pip and install Python packages
pip install --upgrade pip
pip install -r requirements.txt

# Create Django project if it doesn't exist
if [ ! -f manage.py ]; then
  django-admin startproject mysite .
fi

# Configure PostgreSQL database and user if not already present
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = 'mysite_db'" | grep -q 1 || sudo -u postgres psql <<EOF
CREATE DATABASE mysite_db;
CREATE USER mysite_user WITH PASSWORD 'securepassword';
ALTER ROLE mysite_user SET client_encoding TO 'utf8';
ALTER ROLE mysite_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE mysite_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE mysite_db TO mysite_user;
EOF

# Update Django settings.py to use PostgreSQL if not already updated
SETTINGS_FILE="mysite/settings.py"

if ! grep -q "ENGINE': 'django.db.backends.postgresql'" "$SETTINGS_FILE"; then
  sed -i "s/'ENGINE': 'django.db.backends.sqlite3'/'ENGINE': 'django.db.backends.postgresql'/" "$SETTINGS_FILE"
  sed -i "s/'NAME': BASE_DIR \/ 'db.sqlite3'/'NAME': 'mysite_db',\n        'USER': 'mysite_user',\n        'PASSWORD': 'securepassword',\n        'HOST': 'localhost',\n        'PORT': '5432'/" "$SETTINGS_FILE"
  echo -e "\nSTATIC_ROOT = os.path.join(BASE_DIR, 'static/')\n" >> "$SETTINGS_FILE"
fi

# Run Django migrations and collect static files
python manage.py migrate
python manage.py collectstatic --noinput

# Start Gunicorn server in the background
gunicorn mysite.wsgi:application --bind 0.0.0.0:8000 --daemon

echo "✅ Django installed and running at http://<server-ip>:8000"
