import os
import re
import sys
import traceback
from pathlib import Path
import shutil

# Try importing required packages
try:
    import markdown
    import yaml
    from bs4 import BeautifulSoup
except ImportError:
    print("Error: Required packages not found. Please install them using:")
    print("pip install markdown pyyaml beautifulsoup4")
    sys.exit(1)

# Configuration
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_DIR = SCRIPT_DIR
OUTPUT_DIR = os.path.join(SCRIPT_DIR, '_site')
LAYOUT_DIR = os.path.join(SCRIPT_DIR, '_layouts')
CONFIG_FILE = os.path.join(SCRIPT_DIR, '_config.yml')

# Make sure the output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Load config file
config = {}
if os.path.exists(CONFIG_FILE):
    with open(CONFIG_FILE, 'r') as f:
        config = yaml.safe_load(f) or {}

# Get base URL from config or default to ''
base_url = config.get('baseurl', '')
site_title = config.get('title', 'Flutter Riverpod Clean Architecture')
site_description = config.get('description', 'Documentation for Flutter Riverpod Clean Architecture')

# Load the layout template
layout_file = os.path.join(LAYOUT_DIR, 'default.html')
if os.path.exists(layout_file):
    with open(layout_file, 'r') as f:
        layout_template = f.read()
else:
    print(f"Error: Layout file not found at {layout_file}")
    sys.exit(1)

# Function to convert markdown to HTML with front matter processing
def convert_markdown_to_html(markdown_file, output_file):
    print(f"Converting {markdown_file} to {output_file}")
    
    with open(markdown_file, 'r') as f:
        content = f.read()
    
    # Check for front matter (YAML between --- lines)
    front_matter = {}
    content_to_convert = content
    
    front_matter_match = re.match(r'^---\s*\n(.*?)\n---\s*\n(.*)', content, re.DOTALL)
    if front_matter_match:
        try:
            front_matter_content = front_matter_match.group(1)
            content_to_convert = front_matter_match.group(2)
            front_matter = yaml.safe_load(front_matter_content)
        except Exception as e:
            print(f"Warning: Error parsing front matter in {markdown_file}: {e}")
    
    # Get filename without extension for title
    filename = os.path.basename(markdown_file)
    file_title = os.path.splitext(filename)[0].replace('_', ' ').title()
    
    # Use front matter title if available, otherwise use filename
    page_title = front_matter.get('title', file_title)
    
    # Convert markdown to HTML
    html_content = markdown.markdown(
        content_to_convert,
        extensions=[
            'markdown.extensions.fenced_code',
            'markdown.extensions.tables',
            'markdown.extensions.toc',
            'markdown.extensions.codehilite',
            'markdown.extensions.smarty'
        ]
    )
    
    # Apply layout template
    page_content = layout_template.replace('{{ content }}', html_content)
    
    # Replace other variables
    page_content = page_content.replace('{{ page.title }}', page_title)
    page_content = page_content.replace('{% if page.title %}{{ page.title }} - {% endif %}', f"{page_title} - ")
    
    # Get relative URL for active link highlighting
    relative_url = '/' + os.path.relpath(output_file, OUTPUT_DIR)
    page_content = page_content.replace('{{ page.url }}', relative_url)
    
    # Apply active link highlighting
    output_filename = os.path.basename(output_file)
    
    # Get the link to the current file in the sidebar
    current_link = f'/flutter_riverpod_clean_architecture/{output_filename}'
    
    # Replace that link's class to include 'active'
    soup = BeautifulSoup(page_content, 'html.parser')
    for anchor in soup.select(f'a[href="{current_link}"]'):
        anchor['class'] = anchor.get('class', []) + ['active']
    
    # Update page content with the modified soup
    page_content = str(soup)
    
    # Write the HTML file
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(page_content)

# Process all markdown files
def process_markdown_files():
    for root, _, files in os.walk(INPUT_DIR):
        for file in files:
            if file.endswith('.md'):
                # Skip files in _layouts directory
                if '/_layouts/' in root or '/_site/' in root:
                    continue
                
                # Convert Markdown to HTML
                markdown_file = os.path.join(root, file)
                rel_path = os.path.relpath(markdown_file, INPUT_DIR)
                
                # Convert filenames like FEATURE_FLAGS_GUIDE.md to feature_flags.html
                output_filename = os.path.splitext(file)[0].lower().replace('_guide', '')
                
                # Special case for index.md
                if file.lower() == 'readme.md' and os.path.dirname(rel_path) == '.':
                    output_filename = 'index'
                
                output_file = os.path.join(OUTPUT_DIR, f"{output_filename}.html")
                convert_markdown_to_html(markdown_file, output_file)

# Process HTML files with front matter
def process_html_files():
    for root, _, files in os.walk(INPUT_DIR):
        for file in files:
            if file.endswith('.html') and file not in ['index.html', 'default.html']:
                # Skip files in _layouts directory or already processed files
                if '/_layouts/' in root or '/_site/' in root:
                    continue
                    
                # Copy the HTML files
                html_file = os.path.join(root, file)
                rel_path = os.path.relpath(html_file, INPUT_DIR)
                dest_file = os.path.join(OUTPUT_DIR, rel_path)
                
                shutil.copy2(html_file, dest_file)
                print(f"Copied HTML file: {rel_path}")

# Special handling for index.html with front matter
def process_index_html():
    index_file = os.path.join(INPUT_DIR, 'index.html')
    if not os.path.exists(index_file):
        print("Warning: index.html not found")
        return
        
    print(f"Processing index.html with front matter")
    
    with open(index_file, 'r') as f:
        content = f.read()
    
    # Check for front matter (YAML between --- lines)
    front_matter = {}
    content_to_convert = content
    
    front_matter_match = re.match(r'^---\s*\n(.*?)\n---\s*\n(.*)', content, re.DOTALL)
    if front_matter_match:
        try:
            front_matter_content = front_matter_match.group(1)
            content_to_convert = front_matter_match.group(2)
            front_matter = yaml.safe_load(front_matter_content)
        except Exception as e:
            print(f"Warning: Error parsing front matter in index.html: {e}")
    
    # Get title from front matter
    page_title = front_matter.get('title', 'Home')
    
    # Load the layout template
    with open(os.path.join(LAYOUT_DIR, 'default.html'), 'r') as f:
        layout_template = f.read()
    
    # Replace content placeholder in layout
    page_content = layout_template.replace('{{ content }}', content_to_convert)
    
    # Replace title placeholder
    page_content = page_content.replace('{{ page.title }}', page_title)
    
    # Process sidebar active link
    soup = BeautifulSoup(page_content, 'html.parser')
    for anchor in soup.select('a[href="/flutter_riverpod_clean_architecture/index.html"]'):
        anchor['class'] = anchor.get('class', []) + ['active']
    
    # Update page content with the modified soup
    page_content = str(soup)
    
    # Write the final index.html
    output_file = os.path.join(OUTPUT_DIR, 'index.html')
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(page_content)
    
    print("Processed index.html successfully")

# Copy static files (CSS, JS, images, etc.) - keeping directory structure
def copy_static_files():
    for root, _, files in os.walk(INPUT_DIR):
        for file in files:
            # Skip markdown files and already processed files
            if file.endswith(('.md', '.yml')) or '/_layouts/' in root or '/_site/' in root:
                continue
            
            # Copy the file keeping the directory structure
            source_file = os.path.join(root, file)
            rel_path = os.path.relpath(source_file, INPUT_DIR)
            dest_file = os.path.join(OUTPUT_DIR, rel_path)
            
            os.makedirs(os.path.dirname(dest_file), exist_ok=True)
            shutil.copy2(source_file, dest_file)
            print(f"Copied static file: {rel_path}")

# Main execution
if __name__ == "__main__":
    try:
        print(f"Starting conversion from {INPUT_DIR} to {OUTPUT_DIR}")
        
        # Check if the layout file exists
        if not os.path.exists(os.path.join(LAYOUT_DIR, 'default.html')):
            print(f"Error: Layout file not found at {os.path.join(LAYOUT_DIR, 'default.html')}")
            sys.exit(1)
        
        process_markdown_files()
        process_html_files()
        process_index_html()
        copy_static_files()
        print("Conversion complete!")
    except Exception as e:
        print(f"Error during conversion: {e}")
        print("Stack trace:")
        traceback.print_exc()
        sys.exit(1)
