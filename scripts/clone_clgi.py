#!/usr/bin/env python3
import os
import requests
from urllib.parse import urljoin, urlparse
from bs4 import BeautifulSoup
import sys

def download_file(url, save_folder):
    os.makedirs(save_folder, exist_ok=True)
    local_filename = os.path.join(save_folder, os.path.basename(urlparse(url).path))
    # Add extension if missing and not static resource
    if not local_filename.lower().endswith(('.css', '.js', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico')):
        local_filename += '.file'
    try:
        r = requests.get(url, timeout=10)
        r.raise_for_status()
        with open(local_filename, 'wb') as f:
            f.write(r.content)
        print(f"Downloaded {url} -> {local_filename}")
        return local_filename
    except Exception as e:
        print(f"Failed to download {url}: {e}")
        return None

def rewrite_urls(soup, tag, attr, base_url, static_dir):
    for element in soup.find_all(tag):
        url = element.get(attr)
        if not url:
            continue
        full_url = urljoin(base_url, url)
        local_path = download_file(full_url, static_dir)
        if local_path:
            # Use relative path for href/src
            element[attr] = os.path.relpath(local_path, static_dir)

def clone_website(base_url, mode='full', output_dir='/home/ec2-user/sandbox'):
    os.makedirs(output_dir, exist_ok=True)
    static_dir = os.path.join(output_dir, 'static')
    os.makedirs(static_dir, exist_ok=True)

    print(f"Fetching {base_url} ...")
    r = requests.get(base_url)
    r.raise_for_status()
    soup = BeautifulSoup(r.text, 'html.parser')

    # Always rewrite CSS links
    rewrite_urls(soup, 'link', 'href', base_url, static_dir)

    if mode == 'full':
        rewrite_urls(soup, 'script', 'src', base_url, static_dir)
        rewrite_urls(soup, 'img', 'src', base_url, static_dir)
        rewrite_urls(soup, 'link', 'href', base_url, static_dir)  # favicon etc.

    # Save modified HTML to index.html in static folder
    index_file = os.path.join(static_dir, 'index.html')
    with open(index_file, 'w', encoding='utf-8') as f:
        f.write(soup.prettify())

    print(f"Website cloned in {mode} mode to {output_dir}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python clone_clgi.py <URL> [basic|full]")
        sys.exit(1)

    base_url = sys.argv[1]
    mode = sys.argv[2] if len(sys.argv) > 2 else 'full'

    if mode not in ['basic', 'full']:
        print("Mode must be 'basic' or 'full'")
        sys.exit(1)

    clone_website(base_url, mode)
