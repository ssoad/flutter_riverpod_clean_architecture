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
- **Analytics Integration** — Flexible analytics system for tracking user behavior and app performance
- **Push Notifications** — Complete notification handling with deep linking and background processing
- **Biometric Authentication** — Secure fingerprint and face recognition support
- **Feature Flags** — A/B testing and staged rollouts with remote configuration
- **Advanced Image Handling** — Lazy loading, caching, SVG support, image effects, and animated placeholders
- **Structured Logging** — Comprehensive logging system with levels, tags, and performance tracking
- **Advanced Caching System** — Memory and disk caching with TTL, encryption, and type-safe APIs
- **Dynamic Theming** — Customizable themes with light/dark mode support and persistence
- **Comprehensive Utilities** — Rich set of extensions for DateTime, BuildContext, Widget, String, and more
- **Error Handling** — Consistent error handling with custom Failure classes
- **Dependency Injection** — Clean dependency management with Riverpod
- **Accessibility** — Complete accessibility support with screen reader, high contrast, and dynamic text sizes
- **Offline-First Architecture** — Keep working offline with queued changes and smart synchronization
- **App Update Flow** — Force updates, in-app updates, and update notifications
- **App Review System** — Smart rating prompts and feedback collection
- **CI/CD Integration** — GitHub Actions workflows and Fastlane scripts for automated delivery
- **Code Generation Tools** — Feature generator for rapid development
- **Project Renaming Tools** — Easy app and package renaming across all platforms
- **Example Implementations** — Ready-to-use screens demonstrating the architecture
- **Extensive Documentation** — Detailed guides for architecture, utilities, and extensions

## 📖 Documentation

Comprehensive documentation is available in the `/docs` folder:

- [Architecture Guide](docs/ARCHITECTURE_GUIDE.md) - Detailed explanation of the project structure and principles
- [Utilities Guide](docs/UTILITIES_GUIDE.md) - How to use the utility extensions and helpers
- [Localization Guide](docs/LOCALIZATION_GUIDE.md) - Complete guide to multi-language support
- [Image Handling Guide](docs/IMAGE_HANDLING_GUIDE.md) - Advanced guide for image loading, processing, and effects
- [Biometric Auth Guide](docs/BIOMETRIC_AUTH_GUIDE.md) - Implementing secure biometric authentication
- [Feature Flags Guide](docs/FEATURE_FLAGS_GUIDE.md) - Using feature flags and remote configuration
- [Analytics Guide](docs/ANALYTICS_GUIDE.md) - Tracking and analyzing user behavior
- [Accessibility Guide](docs/ACCESSIBILITY_GUIDE.md) - Making your app accessible to all users
- [Offline Architecture Guide](docs/OFFLINE_ARCHITECTURE_GUIDE.md) - Building offline-first apps
- [CI/CD Guide](docs/CICD_GUIDE.md) - Setting up continuous integration and delivery
- [Interactive Documentation](docs/index.html) - Browser-based interactive documentation with examples
- [DateTime Extensions Guide](docs/datetime_extensions.html) - Complete reference for date and time utilities
- [Advanced Features Summary](docs/ADVANCED_FEATURES_SUMMARY.md) - Overview of all advanced features

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

### Analytics Integration

Track user interactions and app performance with a flexible analytics system:

```dart
// Access analytics
final analytics = ref.watch(analyticsProvider);

// Log screen views
analytics.logScreenView('HomeScreen', parameters: {'referrer': 'deeplink'});

// Log user actions
analytics.logUserAction(
  action: 'button_tap',
  category: 'engagement',
  label: 'sign_up_button',
);

// Track errors
analytics.logError(
  errorType: 'network_error',
  message: 'Failed to fetch user data',
  isFatal: false,
);

// Measure performance
analytics.logPerformance(
  name: 'image_processing',
  value: 340.5,
  unit: 'ms',
);

// Use automatic screen tracking
return AnalyticsScreenView(
  screenName: 'ProductDetailsScreen',
  parameters: {'product_id': product.id},
  child: Scaffold(/* ... */),
);
```

### Push Notifications

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

- **Analytics**: Comprehensive event tracking with privacy controls
- **Authentication**: Secure biometric authentication with session management
- **Feature Flags**: Runtime feature toggling with A/B testing support
- **Images**: Advanced image handling with processing, caching, SVG support, visual effects, and animated placeholders
- **Localization**: Multi-language support with context extensions and asset localization
- **Logging**: Structured logging with levels, tags, and performance tracking
- **Notifications**: Complete push notification system with deep linking
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

## � Advanced Features

### Accessibility

Make your app inclusive and usable by everyone:

```dart
// Access accessibility settings
final accessibilitySettings = ref.watch(accessibilitySettingsProvider);

// Check if screen reader is active
if (accessibilitySettings.isScreenReaderActive) {
  // Provide additional context for screen readers
}

// Announce messages to screen reader
final notifier = ref.read(accessibilitySettingsProvider.notifier);
notifier.announce('Item added to cart successfully');

// Use accessible widgets
AccessibleButton(
  onPressed: () => doSomething(),
  semanticLabel: 'Save changes',
  child: Text('Save'),
)

// Extend regular widgets with accessibility
myButton.withMinimumTouchTargetSize()
myImage.withSemanticLabel('Profile picture')
```

See the [Accessibility Guide](/docs/ACCESSIBILITY_GUIDE.md) for more details.

### Offline-First Architecture

Keep your app working seamlessly with or without an internet connection:

```dart
// Queue changes when offline
await offlineSyncService.queueChange(
  entityType: 'task',
  operationType: OfflineOperationType.create,
  data: {
    'title': 'Buy groceries',
    'completed': false,
  },
);

// Watch for pending changes
final pendingChanges = ref.watch(pendingChangesProvider);
pendingChanges.when(
  data: (changes) => Text('Pending changes: ${changes.length}'),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => Text('Error'),
);

// Show sync status
OfflineStatusIndicator()
```

See the [Offline Architecture Guide](/docs/OFFLINE_ARCHITECTURE_GUIDE.md) for more details.

### App Update Flow

Manage app updates with customizable flows:

```dart
// Check for updates
final updateController = ref.read(updateControllerProvider.notifier);
await updateController.checkForUpdates();

// Show update dialog
if (result == UpdateCheckResult.updateAvailable) {
  final updateInfo = await updateController.getUpdateInfo();
  showDialog(
    context: context,
    builder: (context) => UpdateDialog(
      updateInfo: updateInfo!,
      isCritical: false,
    ),
  );
}

// Force critical updates
if (result == UpdateCheckResult.criticalUpdateRequired) {
  // Prevent app usage until updated
}
```

### App Review System

Get feedback and ratings from your users:

```dart
final reviewService = ref.read(appReviewServiceProvider);

// Record significant actions that might trigger a review
await reviewService.recordSignificantAction();

// Show feedback form before store review
final hasFeedback = await reviewService.showFeedbackForm(
  context: context,
  title: "Enjoying the App?",
  message: "We'd love to hear your feedback!",
);

// Request store review
if (shouldRequestReview) {
  await reviewService.requestReview();
}
```

### CI/CD Integration

Automated build, test, and deployment workflows:

```bash
# Build for development
fastlane android build env:development

# Deploy to TestFlight
fastlane ios deploy env:production
```

See the [CI/CD Guide](/docs/CICD_GUIDE.md) for more details.

## �📚 Further Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- [Advanced Features Summary](/docs/ADVANCED_FEATURES_SUMMARY.md)
