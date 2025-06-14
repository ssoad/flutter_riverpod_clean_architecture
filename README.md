# Flutter Riverpod Clean Architecture

![Flutter](https://img.shields.io/badge/Flutter-3.7+-02569B.svg?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2.svg?style=flat&logo=dart)
![Riverpod](https://img.shields.io/badge/Riverpod-2.0+-0175C2.svg?style=flat)
![License](https://img.shields.io/badge/License-MIT-purple.svg)

A production-ready Flutter project template implementing Clean Architecture principles with Riverpod for state management. This template provides a solid foundation for building scalable, maintainable, and testable Flutter applications.

<p align="center">
  <img src="https://flutter.dev/assets/images/shared/brand/flutter/logo/flutter-lockup.png" alt="Flutter" height="100"/>
</p>

## 🌟 Features

- **Clean Architecture** — Separation of concerns with domain, data, and presentation layers
- **Riverpod State Management** — Powerful and testable state management solution
- **Multi-language Support** — Full internationalization with easy language switching and localized assets
- **Locale-Aware Navigation** — Router integration with locale-based navigation support
- **Advanced Caching System** — Memory and disk caching with TTL, encryption, and type-safe APIs
- **Dynamic Theming** — Customizable themes with light/dark mode support and persistence
- **Comprehensive Utilities** — Rich set of extensions for DateTime, BuildContext, Widget, String, and more
- **Error Handling** — Consistent error handling with custom Failure classes
- **Dependency Injection** — Clean dependency management with Riverpod
- **Code Generation Tools** — Feature generator for rapid development
- **Project Renaming Tools** — Easy app and package renaming across all platforms
- **Example Implementations** — Ready-to-use screens demonstrating the architecture
- **Extensive Documentation** — Detailed guides for architecture, utilities, and extensions

## 📖 Documentation

Comprehensive documentation is available in the `/docs` folder:

- [Architecture Guide](docs/ARCHITECTURE_GUIDE.md) - Detailed explanation of the project structure and principles
- [Utilities Guide](docs/UTILITIES_GUIDE.md) - How to use the utility extensions and helpers
- [Localization Guide](docs/LOCALIZATION_GUIDE.md) - Complete guide to multi-language support
- [Interactive Documentation](docs/index.html) - Browser-based interactive documentation with examples
- [DateTime Extensions Guide](docs/datetime_extensions.html) - Complete reference for date and time utilities

## 🏗️ Project Structure

The project follows a feature-first organization with a core module for shared functionality:

```plaintext
lib/
├── core/            # Core functionality used across features
│   ├── cli/         # Command-line utilities
│   ├── constants/   # App-wide constants
│   ├── docs/        # Documentation helpers
│   ├── error/       # Error handling
│   ├── generators/  # Code generation helpers
│   ├── localization/ # Internationalization
│   ├── network/     # Network services
│   ├── providers/   # Core providers
│   ├── router/      # Routing with locale support
│   ├── storage/     # Local storage & caching
│   ├── theme/       # Theming
│   ├── ui/          # Shared UI components
│   └── utils/       # Utility functions and extensions
├── examples/        # Example implementations
│   ├── cache_example.dart
│   ├── language_selector.dart
│   ├── localization_demo.dart
│   ├── localization_assets_demo.dart
│   └── theme_showcase.dart
├── features/        # Feature modules
│   ├── auth/        # Authentication feature
│   ├── home/        # Home screen feature
│   ├── settings/    # App settings feature
│   └── ui_showcase/ # UI component showcase
├── gen/             # Generated code
├── l10n/            # Localization files
│   └── arb/         # ARB translation files for multiple languages
└── main.dart        # App entry point
```

Each feature follows the Clean Architecture pattern with three layers:

```plaintext
feature/
├── data/            # Data layer
│   ├── datasources/ # Remote and local data sources
│   ├── models/      # Data models
│   └── repositories/ # Repository implementations
├── domain/          # Domain layer
│   ├── entities/    # Business objects
│   ├── repositories/ # Repository interfaces
│   └── usecases/    # Business logic
└── presentation/    # Presentation layer
    ├── providers/   # State management
    ├── screens/     # UI screens
    └── widgets/     # UI components
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- An IDE with Flutter support (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/flutter_riverpod_clean_architecture.git
   ```

2. Navigate to the project directory:

   ```bash
   cd flutter_riverpod_clean_architecture
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app:

   ```bash
   flutter run
   ```

## 🛠️ Utility Scripts

The project includes several utility scripts that help streamline development:

### App Renaming

Easily rebrand your app across all platforms with a single command:

```bash
./rename_app.sh --app-name "Your App Name" --package-name com.yourcompany.appname
```

This script updates:

- App display name in Android, iOS, macOS, Windows, Linux, and Web
- Package/bundle identifiers in all platforms
- File structures and import references
- Build configurations for all supported platforms

### Language Generation

Add new languages or update translations with the localization helper:

```bash
./generate_language.sh --add fr,es,de  # Add French, Spanish, and German
./generate_language.sh --sync           # Synchronize all ARB files with the base English file
./generate_language.sh --gen            # Generate Dart code from ARB files
```

### Feature Generation

Quickly scaffold new features with all the necessary files:

```bash
./create_feature.sh feature_name        # Create a new feature structure
```

## 📝 Core Features

### Multi-language Support

Built-in internationalization with easy language switching:

```dart
// Access translated text
Text(context.tr('common.welcome_message'));

// With parameters
Text(context.tr('user.greeting', {'name': userData.displayName}));

// Format dates based on current locale
Text(context.formatDate(DateTime.now(), 'medium'));

// Format currency based on current locale
Text(context.formatCurrency(19.99));

// Change language
ref.read(localeProvider.notifier).setLocale(const Locale('es'));

// Access language-specific assets
Image.asset(LocalizedAssetService.getLocalizedImagePath('logo.png'));
```

**Key features:**

- Support for multiple languages (English, Spanish, French, German, Japanese, Bengali)
- Automatic locale detection
- Parameter interpolation and pluralization
- Date and currency formatting based on locale
- Persistence of language selection
- Language-specific assets with fallback mechanism
- Locale-aware navigation

### Advanced Caching System

The project implements a robust two-level caching system with both memory and disk storage options:

```dart
// Memory cache configuration
final userMemoryCacheProvider = memoryCacheManagerProvider<UserEntity>();

// Disk cache with type-safe parameters
final userDiskCacheParams = DiskCacheParams<UserEntity>(
  config: CacheConfig(
    maxItems: 100, 
    expiryDuration: Duration(hours: 24),
    encryption: true
  ),
  fromJson: (json) => UserModel.fromJson(json).toEntity(),
  toJson: (user) => UserModel.fromEntity(user).toJson(),
);

final userDiskCacheProvider = diskCacheManagerProvider<UserEntity>(userDiskCacheParams);

// Using the cache
final cacheManager = ref.watch(userDiskCacheProvider);
await cacheManager.setItem('user_1', userEntity);
final cachedUser = await cacheManager.getItem('user_1');
```

**Key features:**

- Type-safe generics for storing any data type
- TTL (Time-To-Live) control for cache expiration
- Optional encryption for sensitive data
- Memory cache for ultra-fast access
- Disk persistence for data that needs to survive app restarts

### Dynamic Theming

The theme system allows for complete customization of app appearance:

```dart
// Access the theme configuration
final themeConfig = ref.watch(themeConfigProvider);
final themeMode = ref.watch(themeModeProvider);

// Use in MaterialApp
return MaterialApp(
  theme: themeConfig.lightTheme,
  darkTheme: themeConfig.darkTheme,
  themeMode: themeMode,
);

// Update theme settings
ref.read(themeConfigProvider.notifier).updatePrimaryColor(Colors.indigo);
ref.read(themeConfigProvider.notifier).updateBorderRadius(8.0);
ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
```

**Key features:**

- Dynamic color palette generation from a primary color
- Runtime theme updates that persist across app restarts
- Independent light and dark theme configuration
- Customizable text styles, shape themes, and component appearances

### Comprehensive Extensions

Utility extensions that simplify common tasks:

```dart
// DateTime extensions
final formattedDate = dateTime.formatAs('MMMM d, yyyy');
final timeAgo = dateTime.timeAgo; // "2 hours ago"
final isToday = dateTime.isToday;

// BuildContext extensions
context.showSnackBar('Operation successful');
final screenSize = context.screenSize;
final isTablet = context.isTablet;

// String extensions
final slug = "Product Title".toSlug(); // "product-title"
final truncated = longString.truncate(20);
```

### Locale-Aware Router

Navigate with locale support using GoRouter:

```dart
// Navigate with the current locale
context.go('/products');

// Navigate with a specific locale
context.goWithLocale('/products', const Locale('es'));

// Get localized routes
final path = LocaleAwareRouter.getLocalizedPath('/settings');
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests for a specific feature
flutter test test/features/auth

# Generate coverage report
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

The project follows a comprehensive testing strategy:

- Unit tests for business logic and utilities
- Widget tests for UI components
- Integration tests for feature workflows
- Golden tests for visual regression

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository

2. Create your feature branch (`git checkout -b feature/amazing-feature`)

3. Commit your changes (`git commit -m 'Add some amazing feature'`)

4. Push to the branch (`git push origin feature/amazing-feature`)

5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔍 Core Modules

- **Localization**: Multi-language support with context extensions and asset localization
- **Error Handling**: Custom Failure class hierarchy for consistent error handling
- **Network**: Type-safe API client with automatic error handling and retry mechanisms
- **Storage**: Secure storage for sensitive data with encryption support
- **Router**: Go Router integration with locale-aware navigation
- **Constants**: App-wide constants for consistent configuration
- **Providers**: Core providers for app-wide state management
- **UI Components**: Reusable widgets that follow the app's design system

### Utility Extensions

- **BuildContext Extensions**: Easy access to theme, localization, navigation, and screen properties
- **DateTime Extensions**: Formatting, comparison, manipulation, and human-readable representations
- **String Extensions**: Validation, formatting, and transformation utilities
- **Widget Extensions**: Padding, margin, gesture, and conditional rendering helpers
- **Iterable Extensions**: Collection manipulation and transformation utilities

### Development Tools

- **App Renaming**: Cross-platform app and package name renaming script
- **Localization Management**: Tools for adding and synchronizing translations
- **Feature Generation**: Scaffold new features with clean architecture structure
- **Linting**: Custom lint rules for code quality
- **Documentation**: Comprehensive guides and examples

## 📚 Further Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart)
