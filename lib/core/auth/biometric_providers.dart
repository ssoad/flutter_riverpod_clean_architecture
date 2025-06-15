import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/biometric_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/debug_biometric_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/local_biometric_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/feature_flags/feature_flag_providers.dart';

/// Provider for the biometric authentication service
final biometricServiceProvider = Provider<BiometricService>((ref) {
  // Check if we're in debug mode or if a feature flag is set
  final useDebugService =
      kDebugMode &&
      ref.watch(
        featureFlagProvider('use_debug_biometrics', defaultValue: false),
      );

  // Create the appropriate service implementation
  final service =
      useDebugService ? DebugBiometricService() : LocalBiometricService();

  // Log biometric events to analytics
  final analytics = ref.watch(analyticsProvider);

  // Return a proxy service that logs analytics
  return _AnalyticsBiometricServiceProxy(service, analytics);
});

/// A proxy service that adds analytics logging to biometric operations
class _AnalyticsBiometricServiceProxy implements BiometricService {
  final BiometricService _delegate;
  final Analytics _analytics;

  _AnalyticsBiometricServiceProxy(this._delegate, this._analytics);

  @override
  Future<bool> isAvailable() {
    return _delegate.isAvailable();
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() {
    return _delegate.getAvailableBiometrics();
  }

  @override
  Future<BiometricResult> authenticate({
    required String localizedReason,
    AuthReason reason = AuthReason.appAccess,
    bool sensitiveTransaction = false,
    String? dialogTitle,
    String? cancelButtonText,
  }) async {
    _analytics.logUserAction(
      action: 'biometric_auth_requested',
      category: 'authentication',
      label: reason.toString(),
      parameters: {
        'reason': reason.toString(),
        'sensitive_transaction': sensitiveTransaction,
      },
    );

    final result = await _delegate.authenticate(
      localizedReason: localizedReason,
      reason: reason,
      sensitiveTransaction: sensitiveTransaction,
      dialogTitle: dialogTitle,
      cancelButtonText: cancelButtonText,
    );

    _analytics.logUserAction(
      action: 'biometric_auth_completed',
      category: 'authentication',
      label: result.toString(),
      parameters: {'result': result.toString(), 'reason': reason.toString()},
    );

    return result;
  }
}

/// Provider to check if biometric authentication is available
final biometricsAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.isAvailable();
});

/// Provider to get available biometric types
final availableBiometricsProvider = FutureProvider<List<BiometricType>>((
  ref,
) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.getAvailableBiometrics();
});

/// Controller for managing authentication state
class BiometricAuthController extends ChangeNotifier {
  final BiometricService _service;
  final Analytics _analytics;

  bool _isAuthenticated = false;
  BiometricResult? _lastResult;
  DateTime? _lastAuthTime;

  BiometricAuthController(this._service, this._analytics);

  /// Whether the user is currently authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// The result of the last authentication attempt
  BiometricResult? get lastResult => _lastResult;

  /// When the user was last authenticated
  DateTime? get lastAuthTime => _lastAuthTime;

  /// Authenticate the user with biometrics
  Future<BiometricResult> authenticate({
    required String reason,
    AuthReason authReason = AuthReason.appAccess,
    bool sensitiveTransaction = false,
    String? dialogTitle,
    String? cancelButtonText,
  }) async {
    _lastResult = await _service.authenticate(
      localizedReason: reason,
      reason: authReason,
      sensitiveTransaction: sensitiveTransaction,
      dialogTitle: dialogTitle,
      cancelButtonText: cancelButtonText,
    );

    if (_lastResult == BiometricResult.success) {
      _isAuthenticated = true;
      _lastAuthTime = DateTime.now();

      _analytics.logUserAction(
        action: 'user_authenticated',
        category: 'authentication',
        label: authReason.toString(),
      );
    }

    notifyListeners();
    return _lastResult!;
  }

  /// Clear the authenticated state
  void logout() {
    _isAuthenticated = false;
    _lastAuthTime = null;

    _analytics.logUserAction(
      action: 'user_logged_out',
      category: 'authentication',
    );

    notifyListeners();
  }

  /// Check if authentication is needed (based on timeout)
  bool isAuthenticationNeeded({Duration? timeout}) {
    if (!_isAuthenticated) return true;

    if (timeout != null && _lastAuthTime != null) {
      final now = DateTime.now();
      final sessionExpiry = _lastAuthTime!.add(timeout);
      if (now.isAfter(sessionExpiry)) {
        _isAuthenticated = false;
        return true;
      }
    }

    return false;
  }
}

/// Provider for the biometric auth controller
final biometricAuthControllerProvider =
    ChangeNotifierProvider<BiometricAuthController>((ref) {
      final service = ref.watch(biometricServiceProvider);
      final analytics = ref.watch(analyticsProvider);
      return BiometricAuthController(service, analytics);
    });
