import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:local_auth/error_codes.dart' as auth_error;
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
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: local_auth.AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          sensitiveTransaction: sensitiveTransaction,
          useErrorDialogs: true,
        ),
      );

      return didAuthenticate ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      debugPrint(
        'Biometric authentication error: ${e.message}, code: ${e.code}',
      );

      if (e.code == auth_error.notAvailable) {
        return BiometricResult.notAvailable;
      } else if (e.code == auth_error.notEnrolled) {
        return BiometricResult.notEnrolled;
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        return BiometricResult.lockedOut;
      } else if (e.code == auth_error.passcodeNotSet) {
        return BiometricResult.notEnrolled;
      } else if (e.code == auth_error.otherOperatingSystem) {
        return BiometricResult.notAvailable;
      } else {
        return BiometricResult.error;
      }
    } catch (e) {
      debugPrint('Unexpected biometric error: $e');
      return BiometricResult.error;
    }
  }
}
