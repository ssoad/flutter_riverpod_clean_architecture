# Core Features

This document provides detailed information about the core features in the Flutter Riverpod Clean Architecture template.

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

## Biometric Authentication

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

For more details, see the [Biometric Auth Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/biometric_auth.html).

## Feature Flags

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

For more details, see the [Feature Flags Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/feature_flags.html).

## Advanced Image Handling

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

For more details, see the [Image Handling Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/image_handling.html).

## Multi-language Support

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

For more details, see the [Localization Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/localization.html).

## Advanced Caching System

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

## Dynamic Theming

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

## Accessibility

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

For more details, see the [Accessibility Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/accessibility.html).

## Offline-First Architecture

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

For more details, see the [Offline Architecture Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/offline_architecture.html).

## App Update Flow

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

## App Review System

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
