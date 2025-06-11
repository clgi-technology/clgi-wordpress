#!/bin/bash

echo "🌐 Cloning CLGI.org site layout..."

# Activate Django virtual environment
source /opt/django-env/bin/activate

# Run the clone script
python3 /home/ubuntu/scripts/clone_clgi.py https://www.clgi.org

# Move files into Django project
mv /home/ubuntu/sandbox/static /home/ubuntu/myproject/static/
mv /home/ubuntu/sandbox/static/index.html /home/ubuntu/myproject/templates/index.html

echo "✅ CLGI.org clone integrated into Django project!"
