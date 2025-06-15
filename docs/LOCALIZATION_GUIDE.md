# Localization Guide

This guide explains how to use and extend the localization system in the Flutter Riverpod Clean Architecture project.

## Table of Contents

- [Overview](#overview)
- [Setup](#setup)
- [Usage](#usage)
  - [Basic Translation](#basic-translation)
  - [Translation with Parameters](#translation-with-parameters)
  - [Pluralization](#pluralization)
  - [Date and Currency Formatting](#date-and-currency-formatting)
- [Adding New Languages](#adding-new-languages)
- [Updating Translations](#updating-translations)
- [UI Components](#ui-components)
- [Language-Specific Assets](#language-specific-assets)
- [Working with Riverpod](#working-with-riverpod)
- [Best Practices](#best-practices)

## Overview

This project implements a comprehensive internationalization (i18n) system with:

- Support for multiple languages
- Parametrized messages
- Pluralization
- Date and currency formatting
- Riverpod integration for state management
- Easy-to-use BuildContext extensions

The system combines both ARB-based translations and in-memory translation maps, allowing for flexibility and integration with the Flutter intl system.

## Setup

The localization system uses:

1. **ARB files** - Define translations for each language
2. **Flutter Intl** - Generates Dart code from ARB files
3. **Riverpod providers** - Manage the active locale
4. **BuildContext extensions** - Provide easy access to translations

### Configuration

The `l10n.yaml` file configures the localization system:

```yaml
arb-dir: lib/l10n/arb
template-arb-file: intl_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/gen/l10n
synthetic-package: false
nullable-getter: false
preferred-supported-locales: ["en", "es", "fr", "de", "ja", "bn"]
use-deferred-loading: false
```

## Usage

### Basic Translation

Use the `tr` extension method on BuildContext:

```dart
// In a widget build method
Text(context.tr('welcome_message'));

// For static text keys
final buttonLabel = context.tr('login');
```

### Translation with Parameters

Use the `trParams` extension method for messages with parameters:

```dart
// With named parameters
Text(context.trParams('greeting', {'name': user.displayName}));

// Example message in ARB file: "greeting": "Hello, {name}!"
```

### Pluralization

For messages that change based on count values:

```dart
// With pluralization logic
final itemText = context.tr('itemCount').replaceAll('{count}', items.length.toString());

// ARB definition: 
// "itemCount": "{count, plural, =0{No items} =1{1 item} other{% raw %}{{count}}{% endraw %} items}"
```

### Date and Currency Formatting

Format dates and currencies according to the user's locale:

```dart
// Format date
final formattedDate = context.formatDate(DateTime.now());

// Format time
final formattedTime = context.formatTime(DateTime.now());

// Format date and time together
final formattedDateTime = context.formatDateTime(DateTime.now());

// Format currency
final formattedPrice = context.formatCurrency(19.99);

// Format with custom patterns
final customDate = context.formatDate(DateTime.now(), pattern: 'EEEE, MMMM d, yyyy');
final customTime = context.formatTime(DateTime.now(), pattern: 'HH:mm:ss');
```

### Using the LocalizationService

For more advanced usage or when you need localization outside of widgets, you can use the `LocalizationService`:

```dart
// In a Consumer widget or when you have access to a WidgetRef
final service = ref.read(localizationServiceProvider);
final translatedText = service.translate('welcome_message');
final formattedDate = service.formatDate(DateTime.now());

// Change the app locale
await service.setLocale(const Locale('fr'));
await service.resetToSystemLocale();
```

You can also use the service through BuildContext extensions:

```dart
// Get the service through context
final service = context.localization;

// Or use extension methods directly
await context.setLocale(const Locale('es'));
final currentLocale = context.currentLocale;
```

## Adding New Languages

To add a new supported language:

1. Use the provided generation script (recommended):

   ```bash
   ./generate_language.sh <language_code> "<Language Name>"
   # Example:
   ./generate_language.sh it "Italian"
   ```

   This script will:
   - Create a new ARB file based on the English template
   - Add the language to LocalizationUtils automatically
   - Format the file properly

2. Or manually create a new ARB file in the `lib/l10n/arb` directory named `intl_<language_code>.arb`
   (e.g., `intl_fr.arb` for French)

3. Add translations for all keys defined in the template ARB file (`intl_en.arb`)

4. Ensure the new locale is in the supported locales list in `lib/l10n/l10n.dart`:

   ```dart
   static const List<Locale> supportedLocales = [
     Locale('en'),
     Locale('es'),
     // Add your new locale here
     Locale('fr'),
   ];
   ```

5. Add the language name to `LocalizationUtils.getLocaleName()` in `lib/l10n/app_localizations_delegate.dart`:

   ```dart
   static String getLocaleName(Locale locale) {
     switch (locale.languageCode) {
       case 'en': return 'English';
       case 'es': return 'Español';
       // Add your new language here
       case 'fr': return 'Français';
       default: return locale.languageCode;
     }
   }
   ```

## Updating Translations

To update or add new translation keys:

1. Add the new key to the template ARB file (`intl_en.arb`)
2. Add translations for the key in all other ARB files
3. Rebuild the app to generate updated localization files

## UI Components

The project includes ready-to-use UI components for language selection:

- `LanguageSelectorWidget` - A widget that displays a list of available languages
- `LanguageSelectorDialog` - A dialog for selecting a language
- `LanguagePopupMenuButton` - A popup menu button for selecting a language

Example usage:

```dart
// Show language selector in a dialog
ElevatedButton(
  onPressed: () => LanguageSelectorDialog.show(context),
  child: Text('Select Language'),
);

// Add language button to AppBar
AppBar(
  title: Text('My App'),
  actions: const [
    LanguagePopupMenuButton(),
  ],
);
```

## Language-Specific Assets

The project supports loading different assets based on the user's selected language:

### Directory Structure

Assets are organized by language code in the assets directory:

```
assets/
  ├── images/
  │   ├── common_image.png  # Shared across all languages
  │   ├── en/
  │   │   └── welcome.png  # English-specific image
  │   ├── es/
  │   │   └── welcome.png  # Spanish-specific image
  │   └── fr/
  │       └── welcome.png  # French-specific image
  └── fonts/
```

### Using Localized Assets

The `LocalizedAssetService` and `LocalizedImage` widget make it easy to work with language-specific assets:

```dart
// Using the LocalizedImage widget (automatically uses current locale)
LocalizedImage(
  imageName: 'welcome.png',
  width: 200,
  height: 100,
  fit: BoxFit.cover,
)

// For non-localized images in the common directory
LocalizedImage(
  imageName: 'logo.png',
  useCommonPath: true,
)

// Getting image paths directly
String localizedPath = LocalizedAssetService.getLocalizedImagePath(context, 'welcome.png');
String commonPath = LocalizedAssetService.getCommonImagePath('logo.png');
```

### Fallback Mechanism

If an image isn't available for the current locale, the system will attempt to load:

1. The image for the current locale
2. If not found, the English version (fallback)
3. If still not found, a placeholder or error widget

### Adding New Language-Specific Assets

To add an asset for a specific language:

1. Place the file in the appropriate language directory (e.g., `assets/images/es/` for Spanish)
2. Ensure the filename is consistent across all languages
3. Update the pubspec.yaml if adding a new asset directory

## Working with Riverpod

The system uses Riverpod providers for managing the active locale:

```dart
// Watch the current locale
final currentLocale = ref.watch(localeProvider);

// Change the active locale
ref.read(localeProvider.notifier).setLocale(const Locale('es'));

// Access translations based on the current locale
final translations = ref.watch(translationsProvider);
```

## Best Practices

1. **Use keys with namespaces** - Organize keys with dot notation (e.g., `auth.login`, `home.welcome`)
2. **Add descriptions** - Include descriptions for all keys in ARB files
3. **Handle missing translations** - The system falls back to English if a translation is missing
4. **Use context extensions** - Prefer `context.tr()` over direct access to translation objects
5. **Keep ARB files consistent** - Ensure all languages have the same set of keys
6. **Use parameters** - Avoid concatenating strings, use parameters instead
7. **Test all languages** - Verify UI layout in all supported languages (some may be longer/shorter)
8. **Update all files** - When adding a new key, update all ARB files to avoid missing translations