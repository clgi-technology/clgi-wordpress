#!/bin/bash

echo "🚀 Starting Django installation..."

# Update and install dependencies
apt update && apt upgrade -y
apt install -y python3 python3-pip python3-venv postgresql postgresql-contrib libpq-dev

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

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Create Django project
django-admin startproject mysite .

# Configure PostgreSQL
sudo -u postgres psql <<EOF
CREATE DATABASE mysite_db;
CREATE USER mysite_user WITH PASSWORD 'securepassword';
ALTER ROLE mysite_user SET client_encoding TO 'utf8';
ALTER ROLE mysite_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE mysite_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE mysite_db TO mysite_user;
EOF

# Update Django settings
sed -i "s/ENGINE': 'django.db.backends.sqlite3'/ENGINE': 'django.db.backends.postgresql'/" mysite/settings.py
sed -i "s/NAME': BASE_DIR \/ 'db.sqlite3'/NAME': 'mysite_db',\n        'USER': 'mysite_user',\n        'PASSWORD': 'securepassword',\n        'HOST': 'localhost',\n        'PORT': '5432'/" mysite/settings.py
echo -e "\nSTATIC_ROOT = os.path.join(BASE_DIR, 'static/')\n" >> mysite/settings.py

# Run migrations and collect static files
python manage.py migrate
python manage.py collectstatic --noinput

# Start Gunicorn server
gunicorn mysite.wsgi:application --bind 0.0.0.0:8000 --daemon

echo "✅ Django installed and running at http://<server-ip>:8000"
