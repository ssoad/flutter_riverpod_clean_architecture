import 'package:flutter/material.dart';

/// Interface for feature flag services
abstract class FeatureFlagService {
  /// Initialize the feature flag service
  Future<void> init();

  /// Check if a feature is enabled
  bool isFeatureEnabled(String featureKey);

  /// Get a string value for a feature flag
  String getString(String key, {required String defaultValue});

  /// Get an integer value for a feature flag
  int getInt(String key, {required int defaultValue});

  /// Get a double value for a feature flag
  double getDouble(String key, {required double defaultValue});

  /// Get a boolean value for a feature flag
  bool getBool(String key, {required bool defaultValue});

  /// Get a color value for a feature flag
  Color getColor(String key, {required Color defaultValue});

  /// Fetch the latest configuration from the remote source
  Future<void> fetchAndActivate();

  /// Set default values for feature flags
  void setDefaults(Map<String, dynamic> defaults);

  /// Register a callback to be called when configs are updated
  void addListener(VoidCallback listener);

  /// Unregister a previously registered callback
  void removeListener(VoidCallback listener);

  /// Cleanup resources
  void dispose();
}
