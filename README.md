# Flutter Riverpod Clean Architecture

![Flutter](https://img.shields.io/badge/Flutter-3.7+-02569B.svg?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2.svg?style=flat&logo=dart)
![Riverpod](https://img.shields.io/badge/Riverpod-2.0+-0175C2.svg?style=flat)
![License](https://img.shields.io/badge/License-MIT-purple.svg)

A production-ready Flutter project template implementing Clean Architecture principles with Riverpod for state management. This template provides a solid foundation for building scalable, maintainable, and testable Flutter applications.

<p align="center">
  <img src="https://flutter.dev/assets/images/shared/brand/flutter/logo/flutter-lockup.png" alt="Flutter" height="100"/>
</p>

## 🌟 Key Features

- **Clean Architecture** — Domain, data, and presentation layers separation
- **Riverpod State Management** — Powerful, testable state management
- **Multi-language Support** — Full internationalization with language switching
- **Advanced Caching** — Memory and disk caching with type-safety
- **Biometric Authentication** — Secure fingerprint and face recognition
- **Feature Flags** — A/B testing and staged rollouts
- **Analytics Integration** — Flexible event tracking
- **Push Notifications** — Deep linking and background handling
- **Accessibility** — Screen reader and dynamic text support
- **Offline-First** — Work seamlessly with or without connection
- **CI/CD Ready** — Automated workflows with GitHub Actions

[See All Features](docs/FEATURES.md)

## � Documentation

- [Architecture Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/architecture.html) - Project structure and principles
- [Utility Tools](docs/TOOLS.md) - CLI tools for development
- [Feature Documentation](docs/FEATURES.md) - Core features explained
- [Code Examples](docs/EXAMPLES.md) - Usage examples
- [Online Documentation](https://ssoad.github.io/flutter_riverpod_clean_architecture/) - Complete reference

## 🏗️ Project Structure

```plaintext
lib/
├── core/                       # Core shared functionality
├── features/                   # Feature modules
│   └── feature_name/           # Individual feature
│       ├── data/               # Data layer (repositories, sources)
│       ├── domain/             # Domain layer (entities, use cases)
│       └── presentation/       # UI layer (screens, providers)
├── examples/                   # Example implementations
└── main.dart                   # Application entry point
```

[Full Architecture Overview](docs/ARCHITECTURE.md)

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/ssoad/flutter_riverpod_clean_architecture.git

# Navigate to the project directory
cd flutter_riverpod_clean_architecture

# Install dependencies
flutter pub get

# Run the app
flutter run
```

[Detailed Getting Started Guide](docs/GETTING_STARTED.md)

## 🛠️ Development Tools

The template includes powerful command-line tools to streamline your development workflow:

| | | |
|:--:|:--:|:--:|
| ![App Renamer](https://img.shields.io/badge/-%F0%9F%93%B1%20App%20Renamer-6366f1?style=for-the-badge&logoColor=white) | ![Feature Generator](https://img.shields.io/badge/-%E2%9A%A1%20Feature%20Generator-f43f5e?style=for-the-badge&logoColor=white) | ![Language Generator](https://img.shields.io/badge/-%F0%9F%8C%90%20Language%20Generator-22c55e?style=for-the-badge&logoColor=white) |
| Update app name and package IDs across all platforms | Scaffold new features with clean architecture | Add and manage translations |
| ![Test Generator](https://img.shields.io/badge/-%F0%9F%A7%AA%20Test%20Generator-d946ef?style=for-the-badge&logoColor=white) | ![Feature Creator](https://img.shields.io/badge/-%F0%9F%9B%A0%EF%B8%8F%20Feature%20Creator-ec4899?style=for-the-badge&logoColor=white) | ![CI/CD Tools](https://img.shields.io/badge/-%F0%9F%94%84%20CI/CD%20Tools-0ea5e9?style=for-the-badge&logoColor=white) |
| Create test scaffolds for features | Create new features with boilerplate code | Automate build and deployment |

[Complete Development Tools Documentation](https://ssoad.github.io/flutter_riverpod_clean_architecture/tools.html)

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests for a specific feature
flutter test test/features/auth

# Generate coverage report
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](docs/CONTRIBUTING.md) for more information.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart)

Complete notification handling with deep linking and background processing:

```dart
// Access notification service
final service = ref.watch(notificationServiceProvider);

// Request permission
final status = await service.requestPermission();

// Show a local notification
await service.showLocalNotification(
  id: 'msg-123',
  title: 'New message',
  body: 'You received a new message from John',
  action: '/chat/john',
  channel: 'messages',
);

// Subscribe to topics
await service.subscribeToTopic('news');

// Handle notification taps through the deep link handler
final deepLinkHandler = ref.watch(notificationDeepLinkHandlerProvider);
final pendingDeepLink = deepLinkHandler.pendingDeepLink;
if (pendingDeepLink != null) {
  router.push(pendingDeepLink);
  deepLinkHandler.clearPendingDeepLink();
}
```

### Biometric Authentication

Secure fingerprint and face recognition for protecting sensitive operations:

```dart
// Access biometric authentication
final biometricAuth = ref.watch(biometricAuthControllerProvider);

// Check if biometrics are available
final isAvailable = await ref.watch(biometricsAvailableProvider.future);

// Authenticate the user
if (isAvailable) {
  final result = await biometricAuth.authenticate(
    reason: 'Please authenticate to access your account',
    authReason: AuthReason.appAccess,
  );
  
  if (result == BiometricResult.success) {
    // User authenticated successfully
    navigator.push('/secure_area');
  }
}

// Check if session has expired
if (biometricAuth.isAuthenticationNeeded(timeout: Duration(minutes: 5))) {
  // Re-authenticate the user
}
```

### Feature Flags

Runtime feature toggling for A/B testing and staged rollouts:

```dart
// Access feature flag service
final service = ref.watch(featureFlagServiceProvider);

// Check if a feature is enabled
if (service.isFeatureEnabled('premium_features')) {
  // Show premium features
}

// Get a configuration value
final apiTimeout = service.getInt('api_timeout_ms', defaultValue: 30000);

// Using the provider helpers
final isDarkModeEnabled = ref.watch(featureFlagProvider('enable_dark_mode', defaultValue: true));
final primaryColor = ref.watch(colorConfigProvider('primary_color', defaultValue: Colors.blue));

// Use the feature flag widget
return FeatureFlag(
  featureKey: 'experimental_ui',
  child: NewExperimentalWidget(),
  fallback: ClassicWidget(),
);
```

### Advanced Image Handling

Optimized image loading with caching, SVG support, effects, and beautiful placeholders:

```dart
// Process images
final processor = ref.watch(imageProcessorProvider);
final thumbnail = await processor.generateThumbnail(
  imageData: imageBytes,
  maxDimension: 200,
  quality: 80,
);

// Advanced image widget with shimmer placeholders
return AdvancedImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  placeholder: ShimmerPlaceholder(
    borderRadius: BorderRadius.circular(8),
  ),
  useThumbnailPreview: true,
  fadeInDuration: Duration(milliseconds: 300),
);

// SVG rendering with coloring
SvgImage.asset(
  'assets/images/icon.svg',
  width: 48,
  height: 48,
  color: Theme.of(context).primaryColor,
);

// Apply visual effects to images
ImageTransformer(
  effect: ImageEffectConfig(
    effectType: ImageEffectType.sepia,
    intensity: 0.7,
  ),
  child: Image.network('https://example.com/photo.jpg'),
);
```

### Structured Logging

Comprehensive logging with levels, tags, and performance tracking:

```dart
// Access the logger
final logger = ref.watch(loggerProvider);

// Log with different levels
logger.d('Debug message');
logger.i('User logged in', data: {'user_id': userId});
logger.w('Resource is running low', data: {'memory': '85%'});
logger.e('Operation failed', error: exception, stackTrace: stackTrace);

// Create a tagged logger for a specific component
final apiLogger = ref.watch(taggedLoggerProvider('API'));
apiLogger.i('Request started', data: {'endpoint': '/users'});

// Track performance
final result = logger.timeSync('Sort operation', () {
  return sortItems(largeList);
});

final response = await logger.timeAsync('API request', () async {
  return await api.fetchData();
});

// Use logger mixin in a class
class UserRepository with LoggerMixin {
  Future<User> fetchUser(String id) async {
    logInfo('Fetching user', data: {'id': id});
    try {
      // ... implementation
    } catch (e, stack) {
      logError('Failed to fetch user', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
```

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

For more advanced features, check out the [Advanced Features Summary](https://ssoad.github.io/flutter_riverpod_clean_architecture/advanced_features_summary.html).

## 📚 Further Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- [Advanced Features Summary](https://ssoad.github.io/flutter_riverpod_clean_architecture/advanced_features_summary.html) - Detailed technical features
- [Advanced Features Summary](/docs/ADVANCED_FEATURES_SUMMARY.md)
