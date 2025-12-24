---
title: Features
---

# Core Features

This document provides detailed information about the core features in the Flutter Riverpod Clean Architecture template.

## 🚀 Showcase Features (New!)

### Real-Time Chat (WebSocket)
A full implementation of a WebSocket-based chat application.
- **Access**: `Ref -> ChatProvider`
- **Architecture**: `Stream<Message>` in Domain layer
- **Tech**: `web_socket_channel`, Optimistic UI updates
- **Path**: `lib/features/chat/`

### Complex Survey Form
Advanced form handling with validation and conditional logic.
- **Tech**: `flutter_form_builder`
- **Features**: 
  - Async validation (e.g., username availability)
  - Conditional fields (dependent on previous answers)
  - Custom form inputs
- **Path**: `lib/features/survey/`

---

## Analytics Integration

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
```

For more details, see the [Analytics Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/analytics.html).

## Push Notifications

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
```

## Biometric Authentication

Secure fingerprint and face recognition for protecting sensitive operations:

```dart
// Access biometric authentication
final biometricAuth = ref.watch(biometricAuthControllerProvider);

// Authenticate the user
if (isAvailable) {
  final result = await biometricAuth.authenticate(
    reason: 'Please authenticate to access your account',
    authReason: AuthReason.appAccess,
  );
}
```

For more details, see the [Biometric Auth Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/biometric_auth.html).

## Feature Flags

Runtime feature toggling for A/B testing and staged rollouts:

```dart
// Check if a feature is enabled
if (service.isFeatureEnabled('premium_features')) {
  // Show premium features
}
```

For more details, see the [Feature Flags Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/feature_flags.html).

## Advanced Image Handling

Optimized image loading with caching, SVG support, effects, and beautiful placeholders.

For more details, see the [Image Handling Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/image_handling.html).

## Multi-language Support

Built-in internationalization with easy language switching:

```dart
// Access translated text
Text(context.tr('common.welcome_message'));
```

For more details, see the [Localization Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/localization.html).

## Advanced Caching System

The project implements a robust two-level caching system with both memory and disk storage options.

```dart
// Using the cache
final cacheManager = ref.watch(userDiskCacheProvider);
await cacheManager.setItem('user_1', userEntity);
```

## Dynamic Theming

The theme system allows for complete customization of app appearance.

```dart
// Use in MaterialApp
return MaterialApp(
  theme: themeConfig.lightTheme,
  darkTheme: themeConfig.darkTheme,
  themeMode: themeMode,
);
```

## Accessibility

Make your app inclusive and usable by everyone.

For more details, see the [Accessibility Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/accessibility.html).

## Offline-First Architecture

Keep your app working seamlessly with or without an internet connection.

For more details, see the [Offline Architecture Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/offline_architecture.html).

## App Update Flow

Manage app updates with customizable flows.

## App Review System

Get feedback and ratings from your users.
