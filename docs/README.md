# Flutter Riverpod Clean Architecture Documentation

This folder contains the documentation for the Flutter Riverpod Clean Architecture project. The documentation is built using a custom Markdown to HTML conversion process that makes it more developer-friendly and informative.

## How to Build the Documentation

You can build the documentation locally using the provided script:

```bash
# From the project root
./docs/build_docs.sh
```

This will:
1. Install the required Python dependencies
2. Convert all Markdown files to HTML using our custom template
3. Generate the site in the `docs/_site` folder

## How to View the Documentation Locally

After building, you can serve the documentation locally using a simple HTTP server:

```bash
# From the project root
cd docs/_site
python -m http.server 8000
```

Then open your browser and go to `http://localhost:8000`.

## Documentation Structure

- Each guide is written in Markdown with a `.md` extension
- The layout template is in `docs/_layouts/default.html`
- The main configuration is in `docs/_config.yml`
- Generated HTML files are placed in `docs/_site`

## Adding New Documentation

To add a new guide:

1. Create a new Markdown file in the `docs` directory
2. Add front matter at the top of the file:

```markdown
---
title: Your Guide Title
description: A short description of the guide
---

Content goes here...
```

3. Include the file in the sidebar menu in `docs/_layouts/default.html`
4. Rebuild the documentation

## Best Practices for Documentation

1. Use front matter for title and description
2. Use proper heading levels (start with level 2 since level 1 is from the title)
3. Include code examples with language specifiers
4. Use tables for structured information
5. Include navigation links when appropriate
6. Keep examples concise and focused
7. Include screenshots for UI components when relevant

## GitHub Pages Deployment

The documentation is automatically deployed to GitHub Pages when changes are pushed to the main branch. The workflow is defined in `.github/workflows/docs.yml`.

## Troubleshooting

If you encounter any issues with the documentation build:

1. Check that all Python dependencies are installed
2. Ensure Markdown files have proper front matter
3. Verify that the layout template is correctly formatted
4. Check console output for any specific errors
