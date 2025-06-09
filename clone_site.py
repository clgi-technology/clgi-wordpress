import os
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
import sys

# Get website URL
website_url = sys.argv[1] if len(sys.argv) > 1 else "https://www.clgi.org"

# Create Django-compatible static directory
output_dir = "/home/ubuntu/sandbox/static"
os.makedirs(output_dir, exist_ok=True)

# Fetch main page
response = requests.get(website_url)
if response.status_code == 200:
    soup = BeautifulSoup(response.text, "html.parser")

    # Save HTML content
    with open(f"{output_dir}/index.html", "w", encoding="utf-8") as file:
        file.write(soup.prettify())

    print("✅ Main HTML page saved!")

    # Function to download assets
    def download_asset(tag, attr, file_ext):
        assets = soup.find_all(tag, {attr: True})
        for asset in assets:
            asset_url = urljoin(website_url, asset[attr])
            parsed_url = urlparse(asset_url)
            file_name = os.path.basename(parsed_url.path)

            try:
                asset_response = requests.get(asset_url)
                if asset_response.status_code == 200:
                    asset_path = f"{output_dir}/{file_name}"
                    with open(asset_path, "wb") as asset_file:
                        asset_file.write(asset_response.content)
                    asset[attr] = f"/static/{file_name}"  # Update reference for Django
                    print(f"✅ Downloaded {file_ext}: {file_name}")
            except Exception as e:
                print(f"❌ Failed to download {file_ext}: {asset_url}")

    # Download CSS, images, and JavaScript files
    download_asset("link", "href", "CSS")
    download_asset("img", "src", "Image")
    download_asset("script", "src", "JavaScript")

    # Save updated HTML with local references
    with open(f"{output_dir}/index.html", "w", encoding="utf-8") as file:
        file.write(soup.prettify())

    print("✅ Website fully cloned! Served at http://vm-ip:8000")
else:
    print(f"❌ Failed to fetch website. Status code: {response.status_code}")