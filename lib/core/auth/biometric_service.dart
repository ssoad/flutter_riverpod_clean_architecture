/// Results from biometric authentication attempts
enum BiometricResult {
  /// Authentication succeeded
  success,

  /// Authentication failed due to credentials not being recognized
  failed,

  /// Authentication was cancelled by the user
  cancelled,

  /// No biometrics are enrolled on the device
  notEnrolled,

  /// Biometrics are not available on this device
  notAvailable,

  /// Biometrics are locked out due to too many failed attempts
  lockedOut,

  /// Authentication failed due to a technical error
  error,
}

/// Types of biometric authentication
enum BiometricType {
  /// Fingerprint authentication
  fingerprint,

  /// Face recognition
  face,

  /// Iris scanning
  iris,

  /// Multiple biometric methods are available
  multiple,
}

/// Reason for biometric authentication request
enum AuthReason {
  /// Authentication for app access
  appAccess,

  /// Authentication for a transaction
  transaction,

  /// Authentication for accessing sensitive data
  sensitiveData,
}

/// Interface for biometric authentication services
abstract class BiometricService {
  /// Check if device supports biometric authentication
  Future<bool> isAvailable();

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics();

  /// Authenticate user with biometrics
  Future<BiometricResult> authenticate({
    required String localizedReason,
    AuthReason reason = AuthReason.appAccess,
    bool sensitiveTransaction = false,
    String? dialogTitle,
    String? cancelButtonText,
  });
}
