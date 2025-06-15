# Feature Flags System Guide

This guide explains how to use the feature flags system in the Flutter Riverpod Clean Architecture template.

## Overview

The feature flags system provides:

- Runtime toggling of features
- Remote configuration with Firebase Remote Config (in production)
- Local configuration for development and testing
- Support for different value types (boolean, string, int, double, colors)
- A/B testing capabilities
- Analytics integration

## Directory Structure

```dart
lib/core/feature_flags/
├── feature_flag_service.dart      # Service interface
├── feature_flag_providers.dart    # Riverpod providers
├── local_feature_flag_service.dart # Local implementation
└── remote_feature_flag_service.dart # Remote implementation with Firebase
```

## How to Use

### Check if a feature is enabled

```dart
final isDarkModeEnabled = ref.watch(
  featureFlagProvider('enable_dark_mode', defaultValue: true)
);

if (isDarkModeEnabled) {
  // Use dark theme
} else {
  // Use light theme
}
```

### Get configuration values

```dart
// String config
final apiBaseUrl = ref.watch(
  stringConfigProvider('api_base_url', defaultValue: 'https://api.example.com')
);

// Int config
final cacheTime = ref.watch(
  intConfigProvider('cache_ttl_seconds', defaultValue: 3600)
);

// Double config
final cornerRadius = ref.watch(
  doubleConfigProvider('corner_radius', defaultValue: 8.0)
);

// Color config
final primaryColor = ref.watch(
  colorConfigProvider('primary_color', defaultValue: Colors.blue)
);
```

### Conditional Widget Rendering

Use the `FeatureFlag` widget to conditionally render UI based on feature flags:

```dart
FeatureFlag(
  featureKey: 'enable_premium_features',
  defaultValue: false,
  child: PremiumFeaturesSection(),
  fallback: UpgradePrompt(), // Optional fallback widget
)
```

## Default Configuration

Default values are defined in `feature_flag_providers.dart`:

```dart
const Map<String, dynamic> kDefaultFeatureFlags = {
  // Feature flags
  'enable_dark_mode': true,
  'enable_push_notifications': true,
  'enable_analytics': true,
  // ...other defaults
};
```

## Implementation Details

### Development vs Production

- In debug builds, `LocalFeatureFlagService` is used for quick iteration
- In release builds, `RemoteFeatureFlagService` fetches values from Firebase Remote Config
- Both implementations share the same interface for consistent usage

### Remote Configuration Setup

To set up remote configuration with Firebase:

1. Add Firebase to your project following the [FlutterFire documentation](https://firebase.flutter.dev/docs/overview/).
2. Set up Remote Config in the Firebase Console
3. Define parameters matching the keys used in your code
4. Set conditions for A/B testing or staged rollouts

## Advanced Usage

### Feature Flag Listeners

Register for updates when feature flags change:

```dart
final service = ref.watch(featureFlagServiceProvider);
service.addListener(() {
  // Handle flag changes
  print('Feature flags updated');
});
```

### Manual Fetching

Force a refresh of remote configurations:

```dart
final service = ref.watch(featureFlagServiceProvider);
await service.fetchAndActivate();
```

### Debug Tools

In development, you can override feature flags at runtime:

```dart
// Only works with LocalFeatureFlagService
if (service is LocalFeatureFlagService) {
  service.setValue('enable_dark_mode', false);
}
```

## Analytics Integration

Feature flag changes are automatically tracked in analytics:

```dart
// In feature_flag_providers.dart
service.addListener(() {
  analytics.logUserAction(
    action: 'feature_flags_updated',
    category: 'config',
  );
});
```

## Testing

For testing specific feature configurations:

```dart
// In test files
final mockService = MockFeatureFlagService();
when(mockService.getBool('feature_key', defaultValue: false))
  .thenReturn(true);
```

## Best Practices

1. Use clear, descriptive feature flag names
2. Set sensible defaults for all flags
3. Avoid deeply nested feature flag conditions
4. Document all feature flags in code comments
5. Clean up old feature flags once fully rolled out
6. Test both enabled and disabled states of features
7. Consider security implications of remotely toggled features
