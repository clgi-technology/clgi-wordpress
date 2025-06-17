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
python3 /home/ubuntu/scripts/clone_clgi.py https://www.clgi.org "$MODE"

# Move assets and HTML
mv /home/ubuntu/sandbox/static/* "$STATIC_DIR/" 2>/dev/null || true
mv /home/ubuntu/sandbox/static/index.html "$TEMPLATE_DIR/index.html" 2>/dev/null || true

# Update Django settings if needed
grep -q "'DIRS':" "$BASE_DIR/mysite/settings.py" || \
sed -i "/'APP_DIRS': True,/a \        'DIRS': [os.path.join(BASE_DIR, 'mysite/templates')]," "$BASE_DIR/mysite/settings.py"

echo "✅ CLGI.org clone integrated. Visit http://<server-ip>:8000 to view."
