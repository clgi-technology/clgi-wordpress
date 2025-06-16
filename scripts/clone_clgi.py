import os
import requests
from urllib.parse import urljoin, urlparse
from bs4 import BeautifulSoup

def download_file(url, save_folder):
    os.makedirs(save_folder, exist_ok=True)
    local_filename = os.path.join(save_folder, os.path.basename(urlparse(url).path))
    if not local_filename.endswith(('.css', '.js', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico')):
        # Fallback to generic name if URL ends with /
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
        # Skip if URL is already local
        if url.startswith('http') or url.startswith('//'):
            full_url = urljoin(base_url, url)
            local_path = download_file(full_url, static_dir)
            if local_path:
                # Use relative path for HTML
                element[attr] = os.path.relpath(local_path, static_dir)
        else:
            # For relative URLs, make absolute then download
            full_url = urljoin(base_url, url)
            local_path = download_file(full_url, static_dir)
            if local_path:
                element[attr] = os.path.relpath(local_path, static_dir)

def clone_website(base_url, output_dir='/home/ubuntu/sandbox'):
    os.makedirs(output_dir, exist_ok=True)
    static_dir = os.path.join(output_dir, 'static')
    os.makedirs(static_dir, exist_ok=True)

    print(f"Fetching {base_url} ...")
    r = requests.get(base_url)
    r.raise_for_status()
    soup = BeautifulSoup(r.text, 'html.parser')

    # Rewrite and download CSS
    rewrite_urls(soup, 'link', 'href', base_url, static_dir)
    # Rewrite and download JS
    rewrite_urls(soup, 'script', 'src', base_url, static_dir)
    # Rewrite and download images
    rewrite_urls(soup, 'img', 'src', base_url, static_dir)
    # Also favicon
    rewrite_urls(soup, 'link', 'href', base_url, static_dir)

    # Save modified HTML to static/index.html
    index_file = os.path.join(static_dir, 'index.html')
    with open(index_file, 'w', encoding='utf-8') as f:
        f.write(str(soup.prettify()))

    print(f"Website cloned to {output_dir}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python clone_clgi.py <URL>")
        sys.exit(1)
    clone_website(sys.argv[1])
