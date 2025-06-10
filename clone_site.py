import os
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
import sys
import time
from datetime import datetime, timedelta

# Get website URL
website_url = sys.argv[1] if len(sys.argv) > 1 else "https://www.clgi.org"

# Create Django-compatible static directory
output_dir = "/home/ubuntu/sandbox/static"
error_log_file = "error_log.txt"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Function to log errors with timestamps
def log_error(message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(error_log_file, "a", encoding="utf-8") as log_file:
        log_file.write(f"[{timestamp}] {message}\n")

# Function to clean up old logs
def cleanup_logs(log_file, days=7):
    if os.path.exists(log_file):
        modified_time = datetime.fromtimestamp(os.path.getmtime(log_file))
        if modified_time < datetime.now() - timedelta(days=days):
            os.remove(log_file)
            print(f"🧹 Cleanup: Removed old log file ({log_file}).")

# Fetch main page with error handling
try:
    response = requests.get(website_url, timeout=10)
    response.raise_for_status()
except requests.exceptions.RequestException as e:
    log_error(f"❌ Error fetching website: {e}")
    print(f"❌ Error fetching website. Check {error_log_file} for details.")
    sys.exit(1)

soup = BeautifulSoup(response.text, "html.parser")

# Save HTML content
with open(f"{output_dir}/index.html", "w", encoding="utf-8") as file:
    file.write(soup.prettify())

print("✅ Main HTML page saved!")

# Function to download assets with retry logic
def download_asset(tag, attr, file_ext, retries=3):
    assets = soup.find_all(tag, {attr: True})
    for asset in assets:
        if asset[attr].startswith("http") or asset[attr].startswith("/"):
            asset_url = urljoin(website_url, asset[attr])
            parsed_url = urlparse(asset_url)
            file_name = os.path.basename(parsed_url.path)

            for attempt in range(retries):
                try:
                    asset_response = requests.get(asset_url, timeout=10)
                    asset_response.raise_for_status()
                    asset_path = f"{output_dir}/{file_name}"
                    with open(asset_path, "wb") as asset_file:
                        asset_file.write(asset_response.content)
                    asset[attr] = f"/static/{file_name}"  # Update reference for Django
                    print(f"✅ Downloaded {file_ext}: {file_name}")
                    break  # Exit retry loop on success
                except requests.exceptions.RequestException as e:
                    print(f"⚠️ Retry {attempt+1}/{retries} failed for {file_ext}: {asset_url}")
                    time.sleep(2)  # Wait before retrying

                    if attempt == retries - 1:  # Log only after all retries fail
                        log_error(f"❌ Failed to download {file_ext}: {asset_url}, Error: {e}")
                        print(f"❌ Error downloading {file_ext}. Check {error_log_file} for details.")

# Download CSS, images, and JavaScript files with retry logic
download_asset("link", "href", "CSS")
download_asset("img", "src", "Image")
download_asset("script", "src", "JavaScript")

# Save updated HTML with local references
with open(f"{output_dir}/index.html", "w", encoding="utf-8") as file:
    file.write(soup.prettify())

# Clean up old error logs
cleanup_logs(error_log_file)

print(f"✅ Website fully cloned! Served at http://vm-ip:8000")
print(f"📜 Error log file created: {error_log_file}")