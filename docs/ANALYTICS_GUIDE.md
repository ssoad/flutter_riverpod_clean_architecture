# Analytics System Guide

This guide explains how to use the analytics system in the Flutter Riverpod Clean Architecture template.

## Overview

The analytics system provides:

- Standardized event tracking across the application
- Support for multiple analytics providers (Firebase Analytics, etc.)
- Privacy controls with easy enable/disable options
- Screen view, user action, error, and performance tracking
- User property management
- Debugging tools for development

## Directory Structure

```dart
lib/core/analytics/
├── analytics_event.dart      # Event models and definitions
├── analytics_providers.dart  # Riverpod providers
├── analytics_service.dart    # Service interfaces
└── firebase_analytics_service.dart  # Firebase implementation
```

## How to Use

### Track Screen Views

```dart
final analytics = ref.watch(analyticsProvider);

// Simple screen view
analytics.logScreenView('HomeScreen');

// With additional parameters
analytics.logScreenView('ProductScreen', parameters: {
  'product_id': '123',
  'category': 'electronics',
});
```

### Track User Actions

```dart
analytics.logUserAction(
  action: 'button_click',
  category: 'navigation',
  label: 'settings_button',
);

// With additional parameters
analytics.logUserAction(
  action: 'item_added_to_cart',
  category: 'ecommerce',
  parameters: {
    'product_id': '123',
    'price': 49.99,
    'currency': 'USD',
  },
);
```

### Track Errors

```dart
try {
  // Some operation
} catch (e, stackTrace) {
  analytics.logError(
    errorType: 'api_error',
    message: e.toString(),
    stackTrace: stackTrace.toString(),
  );
}
```

### Track Performance

```dart
final startTime = DateTime.now();
// Perform some operation
final duration = DateTime.now().difference(startTime);

analytics.logPerformance(
  metricName: 'api_request_time',
  value: duration.inMilliseconds,
);
```

### Manage User Properties

```dart
// Set user ID and properties
analytics.setUserProperties(
  userId: 'user-123',
  properties: {
    'subscription_level': 'premium',
    'account_created_date': '2025-01-15',
  },
);

// Clear user data (e.g., on logout)
analytics.resetUser();
```

### Privacy Controls

```dart
final analytics = ref.watch(analyticsProvider);

// Check if analytics is enabled
final isEnabled = analytics.isEnabled;

// Enable analytics
analytics.enable();

// Disable analytics
analytics.disable();
```

## Integration with Feature Flags

Analytics collection can be controlled via feature flags:

```dart
final analyticsEnabled = ref.watch(
  featureFlagProvider('enable_analytics', defaultValue: true),
);

if (analyticsEnabled) {
  analytics.enable();
} else {
  analytics.disable();
}
```

## Event Types

The system supports these standard event types:

1. **ScreenViewEvent** - Page views and screen navigation
2. **UserActionEvent** - User interactions and engagement
3. **ErrorEvent** - Error tracking and crash reporting
4. **PerformanceEvent** - Performance metrics and timing

Custom event types can be created by extending the `AnalyticsEvent` base class.

## Implementation Details

### CompositeAnalyticsService

The system uses a composite pattern to enable multiple analytics providers simultaneously:

```dart
final service = CompositeAnalyticsService([
  FirebaseAnalyticsService(),
  DebugAnalyticsService(),
  // Add other providers as needed
]);
```

### Development vs Production

- Debug builds include `DebugAnalyticsService` for development visibility
- Production builds use `FirebaseAnalyticsService`
- Both implementations share the same interface

## Firebase Integration

To set up Firebase Analytics:

1. Install the firebase_analytics package
2. Configure Firebase in your app
3. Update the FirebaseAnalyticsService implementation to use the actual Firebase SDK

## Best Practices

1. **Consistency**: Use standardized event names and parameters
2. **Privacy**: Only collect what you need and respect user choices
3. **Performance**: Avoid tracking high-frequency events that could impact performance
4. **Clarity**: Use descriptive event names and structured parameters
5. **Testing**: Verify analytics events in development before production

## Debugging

In development, all analytics events are logged to the console via `DebugAnalyticsService`.

## Privacy Considerations

- Always provide a way for users to opt out of analytics
- Document what data is collected in your privacy policy
- Consider regulations like GDPR and CCPA
- Avoid collecting personally identifiable information (PII)
- Consider anonymizing user data where possible
