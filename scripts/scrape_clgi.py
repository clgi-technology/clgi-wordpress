#!/usr/bin/env python3
import os
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse

BASE_URL = "https://www.clgi.org/"
OUTPUT_DIR = "/var/www/html/clgi-demo"

def save_file(path, content, mode='wb'):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, mode) as f:
        f.write(content)

def is_valid_url(url):
    parsed = urlparse(url)
    return parsed.scheme in ('http', 'https')

def get_local_path(url):
    # Strip scheme and domain, then prefix with OUTPUT_DIR
    parsed = urlparse(url)
    path = parsed.path
    if path.endswith('/'):
        path += 'index.html'
    elif not os.path.splitext(path)[1]:
        path += '.html'
    return os.path.join(OUTPUT_DIR, path.lstrip('/'))

def scrape_page(url, visited):
    if url in visited:
        return
    visited.add(url)

    print(f"Scraping {url}")
    try:
        resp = requests.get(url)
        resp.raise_for_status()
    except Exception as e:
        print(f"Failed to fetch {url}: {e}")
        return

    soup = BeautifulSoup(resp.text, 'html.parser')

    # Save HTML content
    local_path = get_local_path(url)
    save_file(local_path, resp.text.encode('utf-8'))

    # Find and download assets + follow internal links
    # Assets: img[src], link[href], script[src]
    tags_attrs = {
        'img': 'src',
        'link': 'href',
        'script': 'src',
    }

    for tag, attr in tags_attrs.items():
        for element in soup.find_all(tag):
            asset_url = element.get(attr)
            if not asset_url:
                continue
            full_url = urljoin(url, asset_url)
            if not is_valid_url(full_url):
                continue

            # Download asset file
            asset_local_path = get_local_path(full_url)
            if not os.path.exists(asset_local_path):
                try:
                    r = requests.get(full_url)
                    r.raise_for_status()
                    save_file(asset_local_path, r.content)
                except Exception as e:
                    print(f"Failed to download asset {full_url}: {e}")

            # Rewrite asset URLs to relative paths
            rel_path = os.path.relpath(asset_local_path, os.path.dirname(local_path))
            element[attr] = rel_path.replace('\\', '/')

    # Save modified HTML with local asset URLs
    save_file(local_path, soup.prettify('utf-8'))

    # Follow internal links (only those within www.clgi.org)
    for a in soup.find_all('a', href=True):
        link = urljoin(url, a['href'])
        if link.startswith(BASE_URL):
            scrape_page(link, visited)

def main():
    print(f"Starting scrape of {BASE_URL} into {OUTPUT_DIR}")
    scrape_page(BASE_URL, set())
    print("Scraping complete.")

if __name__ == '__main__':
    main()
