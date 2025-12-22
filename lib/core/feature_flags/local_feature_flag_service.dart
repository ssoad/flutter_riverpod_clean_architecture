import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/feature_flags/feature_flag_service.dart';

/// A feature flag service implementation that uses local values
/// Useful for development, testing or as a fallback
class LocalFeatureFlagService extends FeatureFlagService {
  final Map<String, dynamic> _values = {};
  final List<VoidCallback> _listeners = [];
  Timer? _simulatedFetchTimer;

  @override
  Future<void> init() async {
    debugPrint('🚩 LocalFeatureFlagService initialized');
  }

  @override
  bool isFeatureEnabled(String featureKey) {
    final value = _values[featureKey];
    if (value is bool) {
      return value;
    }
    return false;
  }

  @override
  String getString(String key, {required String defaultValue}) {
    final value = _values[key];
    if (value is String) {
      return value;
    }
    return defaultValue;
  }

  @override
  int getInt(String key, {required int defaultValue}) {
    final value = _values[key];
    if (value is int) {
      return value;
    }
    return defaultValue;
  }

  @override
  double getDouble(String key, {required double defaultValue}) {
    final value = _values[key];
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    }
    return defaultValue;
  }

  @override
  bool getBool(String key, {required bool defaultValue}) {
    final value = _values[key];
    if (value is bool) {
      return value;
    }
    return defaultValue;
  }

  @override
  Color getColor(String key, {required Color defaultValue}) {
    final value = _values[key];
    if (value is String && value.startsWith('#')) {
      try {
        final hex = value.replaceFirst('#', '');
        final intValue = int.parse(hex, radix: 16);
        if (hex.length == 6) {
          return Color(0xFF000000 + intValue);
        } else if (hex.length == 8) {
          return Color(intValue);
        }
      } catch (e) {
        debugPrint('🚩 Error parsing color: $e');
      }
    }
    return defaultValue;
  }

  @override
  Future<void> fetchAndActivate() async {
    debugPrint('🚩 Fetching remote configs (simulated)');

    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    debugPrint('🚩 Remote configs fetched and activated');
    _notifyListeners();
    return;
  }

  @override
  void setDefaults(Map<String, dynamic> defaults) {
    for (final entry in defaults.entries) {
      if (!_values.containsKey(entry.key)) {
        _values[entry.key] = entry.value;
      }
    }
    debugPrint('🚩 Default values set: $defaults');
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Simulate periodic fetching of remote configs
  void simulatePeriodicFetching({
    Duration interval = const Duration(minutes: 30),
  }) {
    _simulatedFetchTimer?.cancel();
    _simulatedFetchTimer = Timer.periodic(interval, (_) {
      fetchAndActivate();
    });
  }

  /// Update a feature flag value (for testing/development)
  void setValue(String key, dynamic value) {
    _values[key] = value;
    debugPrint('🚩 Feature flag updated: $key = $value');
    _notifyListeners();
  }

  /// Override multiple values at once
  void setValues(Map<String, dynamic> values) {
    _values.addAll(values);
    debugPrint('🚩 Feature flags updated: $values');
    _notifyListeners();
  }

  /// Clear all values
  void clearValues() {
    _values.clear();
    debugPrint('🚩 All feature flags cleared');
    _notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    _simulatedFetchTimer?.cancel();
    _listeners.clear();
  }

  void _notifyListeners() {
    for (final listener in List.of(_listeners)) {
      try {
        listener();
      } catch (e) {
        debugPrint('🚩 Error notifying listener: $e');
      }
    }
  }
}
