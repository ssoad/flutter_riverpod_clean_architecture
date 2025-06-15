# CI/CD Setup Guide

This guide explains how to use the CI/CD configuration in the Flutter Riverpod Clean Architecture template to automate your build, test, and deployment processes.

## Table of Contents

- [Introduction](#introduction)
- [GitHub Actions Configuration](#github-actions-configuration)
- [Fastlane Integration](#fastlane-integration)
- [Environment Variables and Secrets](#environment-variables-and-secrets)
- [Manual Deployment](#manual-deployment)
- [Environment-Specific Configuration](#environment-specific-configuration)
- [Best Practices](#best-practices)

## Introduction

Continuous Integration and Continuous Deployment (CI/CD) automates the process of building, testing, and deploying your application. The template includes:

- GitHub Actions workflows for CI/CD
- Fastlane configuration for streamlined deployment
- Environment-specific configurations
- Secret management

## GitHub Actions Configuration

The template includes a GitHub Actions workflow file at `.github/workflows/flutter_ci_cd.yml` that handles:

### Automated on Push/PR

The workflow triggers automatically on:
- Push to `main` and `develop` branches
- Pull requests to `main` and `develop` branches

### Static Analysis

```yaml
analyze:
  name: Static Analysis
  # Configuration for running Flutter analyze and format check
```

### Tests

```yaml
test:
  name: Run Tests
  # Configuration for running unit and widget tests
  # Includes code coverage report generation
```

### Android Build

```yaml
build_android:
  name: Build Android App
  # Configuration for building Android APK and App Bundle
  # Only runs on push to main
```

### iOS Build

```yaml
build_ios:
  name: Build iOS App
  # Configuration for building iOS IPA
  # Only runs on push to main
```

### Deployment

```yaml
deploy_android:
  name: Deploy Android to Play Store
  # Configuration for deploying to Play Store
  # Only runs on push to main

deploy_ios:
  name: Deploy iOS to TestFlight
  # Configuration for deploying to TestFlight
  # Only runs on push to main
```

## Fastlane Integration

Fastlane automates common tasks like building, testing, and deploying apps. The configuration is in the `fastlane` directory.

### Android Commands

```bash
# Build for development
fastlane android build env:development

# Build for production
fastlane android build env:production

# Deploy to Google Play internal track
fastlane android deploy env:production track:internal

# Deploy to Google Play production
fastlane android deploy env:production track:production
```

### iOS Commands

```bash
# Build for development
fastlane ios build env:development

# Build for production
fastlane ios build env:production

# Deploy to TestFlight
fastlane ios deploy env:production
```

## Environment Variables and Secrets

### Required Secrets (GitHub)

Add these secrets in your GitHub repository settings:

#### Android
- `ANDROID_KEYSTORE_BASE64`: Base64-encoded Android keystore
- `ANDROID_KEYSTORE_PASSWORD`: Keystore password
- `ANDROID_KEY_ALIAS`: Key alias
- `ANDROID_KEY_PASSWORD`: Key password
- `PLAY_STORE_JSON_KEY`: Google Play service account JSON key

#### iOS
- `APPLE_ID`: Apple ID email
- `APP_SPECIFIC_PASSWORD`: App-specific password
- `TEAM_ID`: Apple developer team ID

### Environment Files

Create environment-specific `.env` files in the project root:

#### .env.development
```
APP_VERSION_NAME=1.0.0
APP_VERSION_CODE=1
API_URL=https://api.dev.example.com
```

#### .env.staging
```
APP_VERSION_NAME=1.0.0
APP_VERSION_CODE=1
API_URL=https://api.staging.example.com
```

#### .env.production
```
APP_VERSION_NAME=1.0.0
APP_VERSION_CODE=1
API_URL=https://api.example.com
```

## Manual Deployment

### Setting Up Fastlane (First Time)

```bash
# Install Fastlane
gem install fastlane

# For Android, set up Google Play credentials
fastlane supply init

# For iOS, set up App Store Connect credentials
fastlane pilot init
```

### Android Manual Deployment

```bash
cd android
fastlane android deploy env:production track:internal
```

### iOS Manual Deployment

```bash
cd ios
fastlane ios deploy env:production
```

## Environment-Specific Configuration

### Flutter Environment Setup

Create environment-specific config files:

#### lib/core/config/dev_config.dart
```dart
class AppConfig implements BaseConfig {
  @override
  String get apiUrl => 'https://api.dev.example.com';
  
  @override
  bool get enableAnalytics => false;
}
```

#### lib/core/config/prod_config.dart
```dart
class AppConfig implements BaseConfig {
  @override
  String get apiUrl => 'https://api.example.com';
  
  @override
  bool get enableAnalytics => true;
}
```

### Using Environment Configs

```dart
// main_dev.dart
void main() {
  setupApp(DevConfig());
}

// main_prod.dart
void main() {
  setupApp(ProdConfig());
}
```

### Build Commands

```bash
# Development build
flutter build apk --flavor dev -t lib/main_dev.dart

# Production build
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

## Best Practices

1. **Never commit secrets**: Always use environment variables or secrets management
2. **Version control your CI/CD config**: Keep your workflow files in version control
3. **Test before deploying**: Ensure all tests pass before deploying
4. **Use feature flags**: Decouple deployment from feature releases
5. **Semantic versioning**: Use proper versioning (MAJOR.MINOR.PATCH)
6. **Automate everything**: Avoid manual steps in the deployment process
7. **Monitor releases**: Track crashes and issues after deployment
8. **Keep build times fast**: Optimize and cache dependencies
9. **Create release notes**: Document changes for users
10. **Plan for rollbacks**: Have a strategy to revert to previous versions

By following these practices, you can create a robust CI/CD pipeline that streamlines your development process and reduces the risk of errors in production.
