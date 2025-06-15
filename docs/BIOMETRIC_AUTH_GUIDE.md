---
title: Biometric Authentication Guide
description: Guide to implementing secure biometric authentication in Flutter apps
---

<!-- Heading defined in front matter, no need for duplicate -->

This guide explains how to use the biometric authentication features in the Flutter Riverpod Clean Architecture template.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Implementation](#implementation)
- [Usage](#usage)
  - [Simple Authentication](#simple-authentication)
  - [Authentication with Payload](#authentication-with-payload)
  - [Advanced Settings](#advanced-settings)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The biometric authentication module provides a secure, easy-to-use interface for implementing fingerprint, face recognition, and other biometric authentication methods in your Flutter application.

The module handles:

- Device compatibility detection
- Secure credential storage
- User-friendly prompts and error messages
- Cross-platform support (iOS, Android)
- Graceful fallbacks when biometrics are unavailable

## Features

### Core Features

- **Instant Integration**: Add biometric authentication in minutes with minimal configuration
- **Secure Storage**: Credentials are encrypted and stored with platform-specific security
- **Multiple Biometric Types**: Support for fingerprint, face ID, and other biometric methods
- **Customizable UI**: Tailor prompts and messages to match your app's branding
- **Fallback Mechanisms**: PIN/password fallbacks when biometrics are unavailable
- **Riverpod Integration**: Full support for reactive state management

### Security Features

- **Credential Encryption**: All sensitive data is encrypted at rest
- **Secure Transmission**: Data in transit uses secure channels
- **Tamper Detection**: Verification of biometric integrity
- **Auto-Invalidation**: Credentials can expire after a configured period
- **Session Management**: Track authentication state across app sessions

## Implementation

The biometric authentication system consists of several components:

### Core Service

The `BiometricAuthService` handles all biometric operations:

```dart
class BiometricAuthService {
  final LocalAuthPlugin _localAuth;
  final SecureStorageService _secureStorage;
  
  const BiometricAuthService(this._localAuth, this._secureStorage);
  
  /// Check if biometrics are available on the device
  Future<bool> isBiometricsAvailable() async {
    final canAuthenticate = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return canAuthenticate && isDeviceSupported;
  }
  
  /// Get available biometric types (fingerprint, face ID, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _localAuth.getAvailableBiometrics();
  }
  
  /// Authenticate user with biometrics
  Future<bool> authenticate({
    required String reason,
    String? localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    return await _localAuth.authenticate(
      localizedReason: localizedReason ?? reason,
      options: AuthenticationOptions(
        stickyAuth: stickyAuth,
        useErrorDialogs: useErrorDialogs,
      ),
    );
  }
  
  /// Store credentials securely after successful authentication
  Future<void> storeCredentials({
    required String key, 
    required String value,
  }) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  /// Retrieve stored credentials
  Future<String?> getCredentials(String key) async {
    return await _secureStorage.read(key: key);
  }
  
  /// Delete stored credentials
  Future<void> deleteCredentials(String key) async {
    await _secureStorage.delete(key: key);
  }
}
```

### Providers

The service is exposed through Riverpod providers:

```dart
/// Provider for the local auth plugin
final localAuthProvider = Provider<LocalAuthPlugin>((ref) {
  return LocalAuthentication();
});

/// Provider for secure storage
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return FlutterSecureStorageService();
});

/// Provider for the biometric service
final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  final localAuth = ref.watch(localAuthProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return BiometricAuthService(localAuth, secureStorage);
});

/// Provider for biometric availability
final biometricsAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricAuthServiceProvider);
  return await service.isBiometricsAvailable();
});

/// Provider for biometric types
final biometricTypesProvider = FutureProvider<List<BiometricType>>((ref) async {
  final service = ref.watch(biometricAuthServiceProvider);
  return await service.getAvailableBiometrics();
});
```

### Authentication State

A `StateNotifier` manages the authentication state:

```dart
/// Authentication state
@freezed
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState.initial() = _Initial;
  const factory AuthenticationState.authenticating() = _Authenticating;
  const factory AuthenticationState.authenticated() = _Authenticated;
  const factory AuthenticationState.failed(String reason) = _Failed;
}

/// Authentication state notifier
class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
  final BiometricAuthService _authService;
  
  AuthenticationNotifier(this._authService) 
      : super(const AuthenticationState.initial());
  
  Future<void> authenticate(String reason) async {
    state = const AuthenticationState.authenticating();
    
    try {
      final success = await _authService.authenticate(reason: reason);
      
      if (success) {
        state = const AuthenticationState.authenticated();
      } else {
        state = const AuthenticationState.failed('Authentication canceled');
      }
    } catch (e) {
      state = AuthenticationState.failed(e.toString());
    }
  }
  
  void reset() {
    state = const AuthenticationState.initial();
  }
}

/// Provider for authentication state
final authenticationProvider = StateNotifierProvider<AuthenticationNotifier, AuthenticationState>((ref) {
  final service = ref.watch(biometricAuthServiceProvider);
  return AuthenticationNotifier(service);
});
```

## Usage

### Simple Authentication

The simplest way to add biometric authentication to your app:

```dart
class BiometricLoginScreen extends ConsumerWidget {
  const BiometricLoginScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (authState is _Authenticating)
              const CircularProgressIndicator()
            else if (authState is _Authenticated)
              const Icon(Icons.check_circle, color: Colors.green, size: 100)
            else if (authState is _Failed)
              Text('Authentication failed: ${(authState as _Failed).reason}', 
                style: TextStyle(color: Colors.red)),
              
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () {
                ref.read(authenticationProvider.notifier).authenticate(
                  'Authenticate to access the app'
                );
              },
              child: const Text('Authenticate with Biometrics'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Authentication with Payload

For more advanced usage, such as authenticating to decrypt stored credentials:

```dart
class ProtectedContentScreen extends ConsumerStatefulWidget {
  const ProtectedContentScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<ProtectedContentScreen> createState() => _ProtectedContentScreenState();
}

class _ProtectedContentScreenState extends ConsumerState<ProtectedContentScreen> {
  String? _secret;
  
  @override
  void initState() {
    super.initState();
    _authenticateAndLoadSecret();
  }
  
  Future<void> _authenticateAndLoadSecret() async {
    final authService = ref.read(biometricAuthServiceProvider);
    
    // Authenticate the user
    final success = await authService.authenticate(
      reason: 'Authenticate to view protected content',
    );
    
    if (success) {
      // Retrieve the protected data
      final secret = await authService.getCredentials('protected_data');
      setState(() {
        _secret = secret;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protected Content')),
      body: Center(
        child: _secret != null
            ? Text('Protected content: $_secret')
            : const Text('Authenticate to view protected content'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _authenticateAndLoadSecret,
        child: const Icon(Icons.fingerprint),
      ),
    );
  }
}
```

### Advanced Settings

The module provides customization options:

```dart
// Custom authentication dialog settings
final success = await authService.authenticate(
  reason: 'Login to account',
  localizedReason: context.tr('auth.biometric_prompt'),
  useErrorDialogs: true,
  stickyAuth: true,  // Keep authentication session active when app goes to background
);

// Manage secure credentials with expiration
final tokenService = ref.read(secureTokenServiceProvider);
await tokenService.storeWithExpiration(
  key: 'auth_token',
  value: response.token,
  expiresInHours: 24,
);
```

## Best Practices

1. **Always Provide Alternatives**: Not all devices support biometrics, and not all users are comfortable with them. Always provide alternative authentication methods.

2. **Clear Error Messages**: When biometric authentication fails, provide clear guidance on why it failed and what the user can do next.

3. **Request Only When Necessary**: Don't request biometric authentication for every screen or action. Reserve it for sensitive operations.

4. **Expire Credentials**: Add expiry times to sensitive credentials stored after biometric authentication.

5. **Test on Real Devices**: Biometric authentication cannot be fully tested in emulators. Test on real devices to ensure a smooth user experience.

6. **Respect Privacy Settings**: If a user has declined biometric authentication, remember that preference and don't repeatedly request it.

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Authentication always fails | Check permissions in AndroidManifest.xml and Info.plist |
| "No hardware available" error | The device doesn't have biometric hardware or it's disabled |
| Authentication dialog doesn't appear | Ensure the app is in the foreground and the device is unlocked |
| Authentication succeeds but credentials can't be retrieved | Check for errors in secure storage implementation |

### Device-Specific Considerations

- **Android**: Requires the `USE_BIOMETRIC` permission in the manifest.
- **iOS**: Requires a usage description in Info.plist.
- **Older devices**: May not support the latest biometric features, test for compatibility.

### Testing

For testing biometric authentication:

```dart
// Mock the biometric service in tests
final mockBiometricAuthService = MockBiometricAuthService();
when(mockBiometricAuthService.isBiometricsAvailable()).thenAnswer((_) async => true);
when(mockBiometricAuthService.authenticate(reason: any(named: 'reason')))
    .thenAnswer((_) async => true);

// Override the provider
final container = ProviderContainer(
  overrides: [
    biometricAuthServiceProvider.overrideWithValue(mockBiometricAuthService),
  ],
);
```
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
