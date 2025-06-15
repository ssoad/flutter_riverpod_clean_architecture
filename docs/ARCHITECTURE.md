# Project Architecture

The Flutter Riverpod Clean Architecture template follows Clean Architecture principles with a feature-first organization and a core module for shared functionality.

## Project Structure

```plaintext
lib/
├── main.dart                     # Application entry point
├── core/                         # Core functionality
│   ├── accessibility/            # Accessibility features
│   ├── analytics/                # Analytics services
│   ├── auth/                     # Authentication
│   ├── error/                    # Error handling
│   ├── feature_flags/            # Feature flags
│   ├── images/                   # Image utilities
│   ├── l10n/                     # Localization
│   ├── network/                  # Network handling
│   ├── storage/                  # Local storage & caching
│   ├── theme/                    # Theming
│   ├── ui/                       # Shared UI components
│   ├── utils/                    # Utility functions and extensions
│   └── updates/                  # App update handling
├── examples/                     # Example implementations
│   ├── cache_example.dart
│   ├── language_selector.dart
│   ├── localization_demo.dart
│   ├── localization_assets_demo.dart
│   └── theme_showcase.dart
├── features/                     # Feature modules
│   ├── feature_a/                # Example feature
│   │   ├── data/                 # Data layer (repositories, data sources)
│   │   ├── domain/               # Domain layer (entities, use cases)
│   │   └── presentation/         # UI layer (screens, widgets, controllers)
│   ├── auth/                     # Authentication feature
│   ├── home/                     # Home screen feature
│   ├── settings/                 # App settings feature
│   └── ui_showcase/              # UI component showcase
├── gen/                          # Generated code
└── l10n/                         # Localization resources
    └── arb/                      # ARB translation files for multiple languages
```

## Clean Architecture

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

## Core Modules

The core modules provide shared functionality that can be used across features:

- **Analytics**: Comprehensive event tracking with privacy controls
- **Authentication**: Secure biometric authentication with session management
- **Feature Flags**: Runtime feature toggling with A/B testing support
- **Images**: Advanced image handling with processing, caching, SVG support
- **Localization**: Multi-language support with context extensions
- **Logging**: Structured logging with levels, tags, and performance tracking
- **Notifications**: Complete push notification system with deep linking
- **Error Handling**: Custom Failure class hierarchy for consistent error handling
- **Network**: Type-safe API client with automatic error handling
- **Storage**: Secure storage for sensitive data with encryption support
- **Router**: Go Router integration with locale-aware navigation
- **Constants**: App-wide constants for consistent configuration
- **Providers**: Core providers for app-wide state management
- **UI Components**: Reusable widgets that follow the app's design system

## Utility Extensions

The project includes various extension methods to simplify common tasks:

- **BuildContext Extensions**: Easy access to theme, localization, navigation
- **DateTime Extensions**: Formatting, comparison, manipulation
- **String Extensions**: Validation, formatting, transformation
- **Widget Extensions**: Padding, margin, gesture helpers
- **Iterable Extensions**: Collection manipulation utilities

## Dependency Injection

Riverpod is used for dependency injection and state management:

```dart
// Define a provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final localStorage = ref.watch(localStorageProvider);
  return UserRepositoryImpl(apiClient, localStorage);
});

// Define a state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthNotifier(userRepository);
});

// Consume in UI
final authState = ref.watch(authStateProvider);
authState.when(
  authenticated: (user) => AuthenticatedView(user: user),
  unauthenticated: () => LoginView(),
  loading: () => LoadingView(),
);
```

For a more detailed explanation of the architecture, see the [Architecture Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/architecture.html).
