# Biometric Authentication Guide

This guide explains how to use the biometric authentication system in the Flutter Riverpod Clean Architecture template.

## Overview

The biometric authentication module provides:
- Local device authentication using fingerprint, face recognition, or iris scanning
- Cross-platform support through the `local_auth` package
- Analytics tracking of biometric usage
- Feature flag control to enable/disable biometric authentication

## Directory Structure

```
lib/core/auth/
├── biometric_service.dart     # Service interface and enums
├── biometric_providers.dart   # Riverpod providers
├── debug_biometric_service.dart # Debug implementation
└── local_biometric_service.dart # Real implementation using local_auth
```

## How to Use

### Check if biometrics are available

```dart
final biometricService = ref.watch(biometricServiceProvider);
final isAvailable = await biometricService.isAvailable();

if (isAvailable) {
  // Show biometric authentication option
} else {
  // Fall back to password/PIN
}
```

### Get available biometric types

```dart
final biometricTypes = await biometricService.getAvailableBiometrics();

if (biometricTypes.contains(BiometricType.fingerprint)) {
  // Show fingerprint icon
} else if (biometricTypes.contains(BiometricType.face)) {
  // Show face ID icon
}
```

### Authenticate with biometrics

```dart
final result = await biometricService.authenticate(
  localizedReason: 'Authenticate to access your account',
  reason: AuthReason.appAccess,
  dialogTitle: 'Biometric Authentication',
);

switch (result) {
  case BiometricResult.success:
    // Grant access
    break;
  case BiometricResult.failed:
    // Authentication failed, try again or fall back
    break;
  case BiometricResult.cancelled:
    // User cancelled, show manual login option
    break;
  case BiometricResult.notAvailable:
  case BiometricResult.notEnrolled:
    // Device doesn't support or user hasn't set up biometrics
    break;
  case BiometricResult.lockedOut:
    // Too many failed attempts, fall back to password
    break;
  default:
    // Unexpected error
    break;
}
```

### Feature Flag Control

Biometrics can be enabled/disabled via feature flags:

```dart
final biometricsEnabled = ref.watch(
  featureFlagProvider('enable_biometric_login', defaultValue: true),
);

if (biometricsEnabled) {
  // Show biometric login option
}
```

## Platform Setup

### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

For older Android versions:
```xml
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

### iOS

Add this to your `ios/Runner/Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Why you are using Face ID</string>
```

## Advanced Usage

### Sensitive Transactions

For financial or other sensitive operations:

```dart
final result = await biometricService.authenticate(
  localizedReason: 'Authenticate to confirm payment',
  reason: AuthReason.transaction,
  sensitiveTransaction: true,
);
```

### Custom Analytics

The `biometricServiceProvider` automatically logs analytics events. You can view these in your analytics dashboard.

## Testing

Use the `DebugBiometricService` for testing by setting the `use_debug_biometrics` feature flag to `true` in debug builds.

## Troubleshooting

- **"No hardware available"**: The device doesn't support biometric authentication
- **"No biometrics enrolled"**: The user hasn't set up biometrics on their device
- **"Authentication locked out"**: Too many failed attempts, will typically reset after 30 seconds
- **"Authentication permanently locked out"**: User must unlock with PIN/password first

## Best Practices

1. Always provide alternative authentication methods
2. Use biometrics for low-risk actions or as a second factor
3. Be transparent about how biometric data is used (never stored remotely)
4. Handle all error states gracefully
5. Respect user privacy preferences
