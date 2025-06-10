import os
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
import sys
import time
from datetime import datetime, timedelta
from hashlib import md5
from concurrent.futures import ThreadPoolExecutor

# Get website URL
website_url = sys.argv[1] if len(sys.argv) > 1 else "https://www.clgi.org"

# Define directories
base_dir = "/home/ubuntu/sandbox"
output_dir = f"{base_dir}/static"
log_dir = f"{base_dir}/logs"
error_log_file = f"{log_dir}/error_log.txt"

# Ensure directories exist
os.makedirs(output_dir, exist_ok=True)
os.makedirs(log_dir, exist_ok=True)

# Function to generate unique asset filenames
def generate_unique_filename(url):
    hash_value = md5(url.encode()).hexdigest()[:10]  # Unique hash prefix
    return f"{hash_value}{os.path.splitext(urlparse(url).path)[-1]}"

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
html_file_path = f"{output_dir}/index.html"
with open(html_file_path, "w", encoding="utf-8") as file:
    file.write(soup.prettify())

print("✅ Main HTML page saved!")

# Function to download assets with retry logic
def download_asset(tag, attr, file_ext, retries=3):
    assets = soup.find_all(tag, {attr: True})
    for asset in assets:
        if asset[attr].startswith("http") or asset[attr].startswith("/"):
            asset_url = urljoin(website_url, asset[attr])
            file_name = generate_unique_filename(asset_url)

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

# Multi-threaded asset download
def download_assets_concurrently():
    with ThreadPoolExecutor(max_workers=5) as executor:
        executor.map(lambda args: download_asset(*args), [
            ("link", "href", "CSS"),
            ("img", "src", "Image"),
            ("script", "src", "JavaScript"),
        ])

download_assets_concurrently()

# Save updated HTML with local references
with open(html_file_path, "w", encoding="utf-8") as file:
    file.write(soup.prettify())

# Clean up old error logs
cleanup_logs(error_log_file)

print(f"✅ Website fully cloned! Served at http://vm-ip:8000")
print(f"📜 Error log file created: {error_log_file}")