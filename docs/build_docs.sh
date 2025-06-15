#!/bin/bash

# This script converts markdown files to HTML and generates a complete documentation site

# Create directories if they don't exist
mkdir -p docs/_site
mkdir -p docs/_layouts

# Install required Python packages
pip install markdown pyyaml beautifulsoup4

# Run the conversion script
python docs/convert_docs.py

echo "Documentation site built successfully in docs/_site directory"
