#!/bin/bash

echo "🌐 Integrating CLGI.org clone into Django..."

# Define paths
BASE_DIR="/opt/django-app"
STATIC_DIR="$BASE_DIR/static"
TEMPLATE_DIR="$BASE_DIR/mysite/templates"

# Ensure directories exist
mkdir -p "$STATIC_DIR"
mkdir -p "$TEMPLATE_DIR"

# Run the clone script
python3 /home/ubuntu/scripts/clone_clgi.py https://www.clgi.org

# Move assets and HTML
mv /home/ubuntu/sandbox/static/* "$STATIC_DIR/"
mv /home/ubuntu/sandbox/static/index.html "$TEMPLATE_DIR/index.html"

# Update Django settings if needed
grep -q "'DIRS':" "$BASE_DIR/mysite/settings.py" || \
sed -i "/'APP_DIRS': True,/a \        'DIRS': [os.path.join(BASE_DIR, 'mysite/templates')]," "$BASE_DIR/mysite/settings.py"

echo "✅ CLGI.org clone integrated. Visit http://<server-ip>:8000 to view."
