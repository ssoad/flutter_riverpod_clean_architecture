import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/feature_flags/feature_flag_service.dart';

/// A feature flag service implementation that uses remote configuration
/// In a real app, this would use Firebase Remote Config or a similar service
class RemoteFeatureFlagService extends FeatureFlagService {
  final Map<String, dynamic> _defaultValues = {};
  final Map<String, dynamic> _remoteValues = {};
  final List<VoidCallback> _listeners = [];
  bool _initialized = false;
  Timer? _fetchTimer;

  @override
  Future<void> init() async {
    // In a real implementation, this would initialize the Firebase Remote Config
    debugPrint('🚩 RemoteFeatureFlagService initializing...');

    // Simulate remote config initialization delay
    await Future.delayed(const Duration(seconds: 1));

    // Set default fetch timeout
    _setFetchTimeout(const Duration(hours: 12));

    // Set minimum fetch interval
    _setMinimumFetchInterval(const Duration(hours: 1));

    _initialized = true;
    debugPrint('🚩 RemoteFeatureFlagService initialized');

    // Fetch initial values
    await fetchAndActivate();

    // Setup periodic fetching in background
    _setupPeriodicFetching();

    return;
  }

  /// Set up automatic periodic fetching of remote values
  void _setupPeriodicFetching() {
    _fetchTimer?.cancel();
    _fetchTimer = Timer.periodic(const Duration(hours: 12), (_) {
      fetchAndActivate();
    });
  }

  /// Set the timeout for fetch operations
  void _setFetchTimeout(Duration timeout) {
    // In a real implementation, this would configure the Firebase Remote Config
    debugPrint(
      '🚩 RemoteFeatureFlagService: Set fetch timeout to ${timeout.inSeconds} seconds',
    );
  }

  /// Set the minimum interval between fetch operations
  void _setMinimumFetchInterval(Duration interval) {
    // In a real implementation, this would configure the Firebase Remote Config
    debugPrint(
      '🚩 RemoteFeatureFlagService: Set minimum fetch interval to ${interval.inSeconds} seconds',
    );
  }

  @override
  bool isFeatureEnabled(String featureKey) {
    return getBool(featureKey, defaultValue: false);
  }

  @override
  String getString(String key, {required String defaultValue}) {
    final remoteValue = _remoteValues[key];
    if (remoteValue is String) {
      return remoteValue;
    }

    final defaultConfigValue = _defaultValues[key];
    if (defaultConfigValue is String) {
      return defaultConfigValue;
    }

    return defaultValue;
  }

  @override
  int getInt(String key, {required int defaultValue}) {
    final remoteValue = _remoteValues[key];
    if (remoteValue is int) {
      return remoteValue;
    } else if (remoteValue is String) {
      return int.tryParse(remoteValue) ?? defaultValue;
    }

    final defaultConfigValue = _defaultValues[key];
    if (defaultConfigValue is int) {
      return defaultConfigValue;
    } else if (defaultConfigValue is String) {
      return int.tryParse(defaultConfigValue) ?? defaultValue;
    }

    return defaultValue;
  }

  @override
  double getDouble(String key, {required double defaultValue}) {
    final remoteValue = _remoteValues[key];
    if (remoteValue is double) {
      return remoteValue;
    } else if (remoteValue is int) {
      return remoteValue.toDouble();
    } else if (remoteValue is String) {
      return double.tryParse(remoteValue) ?? defaultValue;
    }

    final defaultConfigValue = _defaultValues[key];
    if (defaultConfigValue is double) {
      return defaultConfigValue;
    } else if (defaultConfigValue is int) {
      return defaultConfigValue.toDouble();
    } else if (defaultConfigValue is String) {
      return double.tryParse(defaultConfigValue) ?? defaultValue;
    }

    return defaultValue;
  }

  @override
  bool getBool(String key, {required bool defaultValue}) {
    final remoteValue = _remoteValues[key];
    if (remoteValue is bool) {
      return remoteValue;
    } else if (remoteValue is String) {
      return remoteValue.toLowerCase() == 'true';
    } else if (remoteValue is num) {
      return remoteValue != 0;
    }

    final defaultConfigValue = _defaultValues[key];
    if (defaultConfigValue is bool) {
      return defaultConfigValue;
    } else if (defaultConfigValue is String) {
      return defaultConfigValue.toLowerCase() == 'true';
    } else if (defaultConfigValue is num) {
      return defaultConfigValue != 0;
    }

    return defaultValue;
  }

  @override
  Color getColor(String key, {required Color defaultValue}) {
    final value = getString(key, defaultValue: '');
    if (value.isEmpty) return defaultValue;

    if (value.startsWith('#')) {
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
    if (!_initialized) {
      await init();
    }

    debugPrint(
      '🚩 RemoteFeatureFlagService: Fetching remote configurations...',
    );

    // In a real implementation, this would fetch values from Firebase Remote Config
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real scenario, we would be getting these values from the remote service
    // Here we just simulate some values for demonstration
    final Map<String, dynamic> fetchedValues = {
      'enable_dark_mode': true,
      'enable_push_notifications': true,
      'enable_analytics': true,
      'enable_biometric_login': true,
      'api_timeout_ms': 20000,
      'home_screen_layout': 'list', // Changed from default 'grid'
      'primary_color': '#FF4CAF50', // Changed from default blue
    };

    // Update our cached remote values
    _remoteValues.addAll(fetchedValues);

    debugPrint('🚩 RemoteFeatureFlagService: Remote configs activated');
    debugPrint('🚩 Fetched values: $_remoteValues');

    _notifyListeners();
    return;
  }

  @override
  void setDefaults(Map<String, dynamic> defaults) {
    _defaultValues.addAll(defaults);
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

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _fetchTimer?.cancel();
    _listeners.clear();
  }
}
