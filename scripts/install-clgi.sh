#!/bin/bash

MODE=${1:-full}  # default to "full" if nothing is passed

echo "🌐 Integrating CLGI.org clone into Django (mode: $MODE)..."

# Define paths
BASE_DIR="/opt/django-app"
STATIC_DIR="$BASE_DIR/static"
TEMPLATE_DIR="$BASE_DIR/mysite/templates"

# Ensure directories exist
mkdir -p "$STATIC_DIR"
mkdir -p "$TEMPLATE_DIR"

# Run the clone script with mode
python3 /home/ec2-user/scripts/clone_clgi.py https://www.clgi.org "$MODE"

# Move assets and HTML
mv /home/ec2-user/sandbox/static/* "$STATIC_DIR/" 2>/dev/null || true
mv /home/ec2-user/sandbox/static/index.html "$TEMPLATE_DIR/index.html" 2>/dev/null || true

# Update Django settings if needed
SETTINGS_FILE="$BASE_DIR/mysite/settings.py"
if ! grep -q "'DIRS':" "$SETTINGS_FILE"; then
    sed -i "/'APP_DIRS': True,/a \        'DIRS': [os.path.join(BASE_DIR, 'mysite/templates')]," "$SETTINGS_FILE"
fi

echo "✅ CLGI.org clone integrated. Visit http://<server-ip>:8000 to view."
