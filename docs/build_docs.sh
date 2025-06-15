#!/bin/bash

# This script converts markdown files to HTML and generates a complete documentation site

# Create output directory if it doesn't exist
mkdir -p docs/_site

# Install required Python packages if not already installed
pip install markdown pyyaml beautifulsoup4 lxml || pip3 install markdown pyyaml beautifulsoup4 lxml

# Run the improved site generator script
python3 docs/build_site.py || python docs/build_site.py

echo "Documentation site built successfully in docs/_site directory"
