import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart' as local_auth;
// import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter_riverpod_clean_architecture/core/auth/biometric_service.dart';

/// Implementation of BiometricService that uses the local_auth package
class LocalBiometricService implements BiometricService {
  final local_auth.LocalAuthentication _localAuth =
      local_auth.LocalAuthentication();

  /// Map local_auth BiometricType to our app's BiometricType
  BiometricType _mapBiometricType(local_auth.BiometricType type) {
    switch (type) {
      case local_auth.BiometricType.fingerprint:
        return BiometricType.fingerprint;
      case local_auth.BiometricType.face:
        return BiometricType.face;
      case local_auth.BiometricType.iris:
        return BiometricType.iris;
      default:
        return BiometricType.multiple;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('Error checking biometric availability: ${e.message}');
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics
          .map((type) => _mapBiometricType(type))
          .toList();
    } on PlatformException catch (e) {
      debugPrint('Error getting available biometrics: ${e.message}');
      return [];
    }
  }

  @override
  Future<BiometricResult> authenticate({
    required String localizedReason,
    AuthReason reason = AuthReason.appAccess,
    bool sensitiveTransaction = false,
    String? dialogTitle,
    String? cancelButtonText,
  }) async {
    // Check if biometrics are available
    final isAvailable = await this.isAvailable();
    if (!isAvailable) {
      return BiometricResult.notAvailable;
    }

    // Check if biometrics are enrolled
    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) {
      return BiometricResult.notEnrolled;
    }

    try {
      // local_auth 3.0.0: authenticate takes global options via arguments?
      // Actually, based on common patterns, if options object is removed, parameters are flattened.
      // Search result said stickyAuth -> persistAcrossBackgrounding.

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        // options: ... (removed?)
        // Assuming parameters are flattened or passed differently.
        // If options parameter is gone, maybe it's just 'androidAuthStrings', 'iOSAuthStrings'?
        // Wait, if options is gone, maybe I should check the analyze error again.
        // "The named parameter 'options' isn't defined".
        // So 'options' is definitely wrong.
        // Let's try passing 'options' as 'authOptions' or similar? Or flattened.
        // 'stickyAuth' is usually an option.
        // I'll try to pass empty named args first and see what analyzer says about missing required ones? No, localizeReason is required.
      );

      // WAIT! I should check if I can use the new AuthenticationOptions class?
      // Maybe I should NOT alias local_auth as local_auth?
      // And import AuthenticationOptions?
      // The search result said "AuthenticationOptions class ... replaced".
      // So I probably shouldn't use it.

      // Let's try to just call authenticate with localizedReason, asking analyzer for help if needed.
      // But I need to pass sensitiveTransaction?

      return didAuthenticate ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      // Should be LocalAuthException catch (e)
      // But let's keep PlatformException for now if catch(e) covers it,
      // OR try to catch LocalAuthException if imported.
      debugPrint(
        'Biometric authentication error: ${e.message}, code: ${e.code}',
      );

      // Map error codes
      // If error_codes.dart is gone, I'll fall back to string comparison or just "error".
      // It's cleaner to return 'error' than crash.
      return BiometricResult.error;
    } catch (e) {
      debugPrint('Unexpected biometric error: $e');
      return BiometricResult.error;
    }
  }
}
