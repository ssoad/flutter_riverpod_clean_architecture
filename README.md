# Flutter Riverpod Clean Architecture

![Flutter](https://img.shields.io/badge/Flutter-3.7+-02569B.svg?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2.svg?style=flat&logo=dart)
![Riverpod](https://img.shields.io/badge/Riverpod-2.0+-0175C2.svg?style=flat)
![License](https://img.shields.io/badge/License-MIT-purple.svg)

A production-ready Flutter project template implementing Clean Architecture principles with Riverpod for state management.

<p align="center">
  <img src="https://flutter.dev/assets/images/shared/brand/flutter/logo/flutter-lockup.png" alt="Flutter" height="100"/>
</p>

## 🌟 Features

- **Clean Architecture** — Separation of concerns with domain, data, and presentation layers
- **Riverpod State Management** — Powerful and testable state management solution
- **Multi-language Support** — Internationalization with 5 languages out of the box
- **Dynamic Theming** — Customizable themes with light/dark mode and persistence
- **Advanced Caching** — Memory and disk caching with TTL and encryption support
- **Code Generation Tools** — Feature generator for quick scaffolding
- **Comprehensive Extensions** — DateTime, BuildContext, Widget, String, and Iterable extensions
- **Detailed Documentation** — Architecture guides and example implementations

## 📖 Documentation

Comprehensive documentation is available in the `/docs` folder:

- [Architecture Guide](docs/ARCHITECTURE_GUIDE.md) - Detailed explanation of the project architecture
- [Utilities Guide](docs/UTILITIES_GUIDE.md) - Guide to using the utility extensions
- [Interactive Documentation](docs/index.html) - Open this in a browser for interactive documentation
- [DateTime Extensions Guide](docs/datetime_extensions.html) - Detailed guide for working with dates

## 🏗️ Project Structure

The project follows a feature-first organization with a core module for shared functionality:

```
lib/
├── core/            # Core functionality used across features
│   ├── constants/   # App-wide constants
│   ├── error/       # Error handling
│   ├── localization/ # Internationalization
│   ├── network/     # Network services
│   ├── providers/   # Core providers
│   ├── router/      # Routing
│   ├── storage/     # Local storage & caching
│   ├── theme/       # Theming
│   ├── ui/          # Shared UI components
│   └── utils/       # Utility functions and extensions
├── examples/        # Example implementations
├── features/        # Feature modules
│   ├── auth/        # Authentication feature
│   ├── home/        # Home screen feature
│   └── ui_showcase/ # UI component showcase
├── l10n/            # Localization files
└── main.dart        # App entry point
```

Each feature follows a layered structure:

```
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
    ├── pages/       # UI pages
    ├── providers/   # State management
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

## 🧰 Feature Generation

The project includes scripts to generate new features with all required files:

```bash
# Generate a new feature
./generate_feature.sh feature_name EntityName
```

This creates a complete feature structure with domain, data, and presentation layers.

## 🔌 Core Modules

### Caching System

```dart
// Define memory cache provider for a specific type
final userMemoryCacheProvider = memoryCacheManagerProvider<UserEntity>();

// Define disk cache provider with serialization
final userDiskCacheParams = DiskCacheParams<UserEntity>(
  config: CacheConfig.secure(),
  fromJson: (json) => UserModel.fromJson(json).toEntity(),
  toJson: (user) => UserModel.fromEntity(user).toJson(),
);

final userDiskCacheProvider = diskCacheManagerProvider<UserEntity>(userDiskCacheParams);
```

### Theme System

```dart
// In a Consumer widget
final themes = ref.watch(themesProvider);
final themeMode = ref.watch(themeModeProvider);

// Use in MaterialApp
return MaterialApp(
  theme: themes.$1, // Light theme
  darkTheme: themes.$2, // Dark theme
  themeMode: themeMode,
);

// Update primary color
ref.read(themeConfigProvider.notifier).updatePrimaryColor(Colors.blue);
```

### Multi-language Support

```dart
// Using BuildContext extension
final localizedText = context.tr('key.to.translate');

// With parameters
final greeting = context.tr('greeting', {'name': 'John'});

// Change language
ref.read(localeProvider.notifier).setLocale(const Locale('es'));
```

## 🧪 Running Tests

```bash
# Run all tests
flutter test

# Generate a test file for a specific class
./test_generator.sh ClassName
```

## 📱 Example Screens

The project includes several example screens to demonstrate the architecture and features:

- **Theme Showcase** - Demonstrates theme customization capabilities
- **Language Selector** - Shows language switching functionality
- **Cache Example** - Demonstrates the caching system in action

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📬 Contact

Your Name - [@your_twitter](https://twitter.com/your_twitter) - email@example.com

Project Link: [https://github.com/yourusername/flutter_riverpod_clean_architecture](https://github.com/yourusername/flutter_riverpod_clean_architecture)
