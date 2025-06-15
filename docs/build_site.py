#!/usr/bin/env python3
"""
Documentation site generator for Flutter Riverpod Clean Architecture
"""
import os
import re
import shutil
import sys
from pathlib import Path

try:
    import markdown
    import yaml
    from bs4 import BeautifulSoup, Tag
except ImportError:
    print("Required packages not found. Install them with:")
    print("pip install markdown pyyaml beautifulsoup4 lxml")
    sys.exit(1)

# Configuration
DOCS_ROOT = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(DOCS_ROOT, "_site")
LAYOUT_PATH = os.path.join(DOCS_ROOT, "_layouts/default.html")

# Create output directory
os.makedirs(OUTPUT_DIR, exist_ok=True)

def get_layout_template():
    """Load the layout template"""
    with open(LAYOUT_PATH, 'r') as file:
        return file.read()

def read_front_matter(content):
    """Extract front matter from content"""
    front_matter = {}
    content_text = content
    
    front_matter_match = re.match(r'^---\s*\n(.*?)\n---\s*\n(.*)', content, re.DOTALL)
    if front_matter_match:
        try:
            front_matter_yaml = front_matter_match.group(1)
            content_text = front_matter_match.group(2)
            front_matter = yaml.safe_load(front_matter_yaml) or {}
        except Exception as e:
            print(f"Warning: Error parsing front matter: {e}")
    
    return front_matter, content_text

def normalize_filename(filename):
    """Convert filenames to standardized format"""
    base_name = os.path.splitext(filename)[0]
    # Remove _GUIDE suffix and convert to lowercase
    return base_name.replace('_GUIDE', '').lower() + '.html'

def process_markdown_file(file_path):
    """Convert a markdown file to HTML using the layout template"""
    print(f"Converting {file_path}")
    
    # Read markdown content
    with open(file_path, 'r') as file:
        content = file.read()
    
    # Extract front matter
    front_matter, markdown_content = read_front_matter(content)
    
    # Get title from front matter or filename
    filename = os.path.basename(file_path)
    default_title = os.path.splitext(filename)[0].replace('_', ' ').title()
    page_title = front_matter.get('title', default_title)
    
    # Convert markdown to HTML
    html_content = markdown.markdown(
        markdown_content,
        extensions=[
            'markdown.extensions.fenced_code',
            'markdown.extensions.tables',
            'markdown.extensions.codehilite',
            'markdown.extensions.toc'
        ]
    )
    
    # Apply layout template
    layout = get_layout_template()
    output = layout.replace('{{ content }}', html_content)
    output = output.replace('{{ page.title }}', page_title)
    
    # Determine output path
    output_filename = normalize_filename(filename)
    if output_filename.lower() == 'readme.html':
        # Special case for README.md
        output_filename = 'index.html' 
    output_path = os.path.join(OUTPUT_DIR, output_filename)
    
    # Highlight active page in sidebar
    soup = BeautifulSoup(output, 'html.parser')
    for a_tag in soup.find_all('a'):
        if 'href' in a_tag.attrs:
            href = a_tag['href']
            if href.endswith(output_filename) or (output_filename == 'index.html' and href.endswith('index.html')):
                a_tag['class'] = a_tag.get('class', []) + ['active']
    
    # Write the output file
    with open(output_path, 'w') as file:
        file.write(str(soup))

def process_html_file(file_path):
    """Process HTML file with front matter"""
    print(f"Processing HTML file: {file_path}")
    
    # Skip layout files
    if '_layouts' in file_path:
        return
        
    # Read HTML content
    with open(file_path, 'r') as file:
        content = file.read()
    
    # Extract front matter
    front_matter, html_content = read_front_matter(content)
    
    if 'layout' in front_matter:
        # If it has a layout defined, apply the layout
        layout = get_layout_template()
        output = layout.replace('{{ content }}', html_content)
        
        # Get title from front matter
        page_title = front_matter.get('title', 'Untitled')
        output = output.replace('{{ page.title }}', page_title)
        
        # Output filename
        output_filename = os.path.basename(file_path)
        output_path = os.path.join(OUTPUT_DIR, output_filename)
        
        # Highlight active page in sidebar
        soup = BeautifulSoup(output, 'html.parser')
        for a_tag in soup.find_all('a'):
            if 'href' in a_tag.attrs:
                href = a_tag['href']
                if href.endswith(output_filename):
                    a_tag['class'] = a_tag.get('class', []) + ['active']
        
        # Write the output file
        with open(output_path, 'w') as file:
            file.write(str(soup))
    else:
        # If no layout is specified, just copy the file
        output_path = os.path.join(OUTPUT_DIR, os.path.basename(file_path))
        shutil.copy2(file_path, output_path)

def copy_assets():
    """Copy assets to the output directory"""
    assets_dir = os.path.join(DOCS_ROOT, 'assets')
    if os.path.exists(assets_dir):
        output_assets_dir = os.path.join(OUTPUT_DIR, 'assets')
        if os.path.exists(output_assets_dir):
            shutil.rmtree(output_assets_dir)
        shutil.copytree(assets_dir, output_assets_dir)
        print(f"Copied assets directory")

def main():
    """Main function to build the documentation"""
    # Process all markdown files
    for file_path in Path(DOCS_ROOT).glob('*.md'):
        process_markdown_file(str(file_path))
    
    # Process HTML files (except those in _layouts and _site)
    for file_path in Path(DOCS_ROOT).glob('*.html'):
        if '_layouts' not in str(file_path) and '_site' not in str(file_path):
            process_html_file(str(file_path))
    
    # Copy assets
    copy_assets()
    
    print(f"Documentation site built successfully in {OUTPUT_DIR}")

if __name__ == '__main__':
    main()
