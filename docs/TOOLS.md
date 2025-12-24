---
title: Utility Tools & Scripts
---

# Utility Tools & Scripts

The Flutter Riverpod Clean Architecture template includes several utility scripts that help streamline development workflows.

## App Renaming

Easily rebrand your app across all platforms with a single command:

```bash
./rename_app.sh --app-name "Your App Name" --package-name com.yourcompany.appname
```

This script updates:

- App display name in Android, iOS, macOS, Windows, Linux, and Web
- Package/bundle identifiers in all platforms
- File structures and import references
- Build configurations for all supported platforms

## Icon Generation

Generate native app icons for all platforms in one command:

1. Place your icon file (1024x1024) at `assets/icon/app_icon.png`.
2. Run the generator script:

```bash
./generate_icons.sh
```

This updates:
- Android `mipmap` resources
- iOS `Assets.xcassets`
- Web `manifest.json` and icons
- Windows/macOS/Linux icon files

## Language Generation

Add new languages or update translations with the localization helper:

```bash
./generate_language.sh --add fr,es,de  # Add French, Spanish, and German
./generate_language.sh --sync           # Synchronize all ARB files with the base English file
./generate_language.sh --gen            # Generate Dart code from ARB files
```

## Feature Generation

Quickly scaffold new features with all the necessary files:

```bash
./generate_feature.sh --name feature_name        # Create a new feature structure
```

This creates a new feature folder with data, domain, and presentation layers according to Clean Architecture principles.

## Test File Generator

Generate test files for a feature:

```bash
./test_generator.sh feature_name
```

This script creates the necessary test files with appropriate boilerplate for the specified feature.

## Documentation Builder

Build the documentation website:

```bash
cd docs && ./build_docs.sh
```

This script converts the Markdown documentation files to HTML and generates a beautiful documentation website.

## Advanced Usage Examples

### Creating a New Feature and Tests

```bash
# Create a new feature called "user_profile"
./generate_feature.sh --name user_profile

# Generate test files for the user_profile feature
./test_generator.sh user_profile
```

### Renaming Your App for Production

```bash
# Rename your app for production release
./rename_app.sh --app-name "My Awesome App" --package-name com.mycompany.awesomeapp
```
