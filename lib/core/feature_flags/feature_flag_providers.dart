import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/feature_flags/feature_flag_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/feature_flags/local_feature_flag_service.dart';

/// Key for default feature flags
const Map<String, dynamic> kDefaultFeatureFlags = {
  // Feature flags
  'enable_dark_mode': true,
  'enable_push_notifications': true,
  'enable_analytics': true,
  'enable_crash_reporting': true,
  'enable_biometric_login': true,

  // Feature parameters
  'cache_ttl_seconds': 3600,
  'api_timeout_ms': 30000,
  'max_retry_count': 3,

  // A/B test variants
  'home_screen_layout': 'grid', // 'grid' or 'list'
  'onboarding_screens_count': 3,

  // Design values
  'primary_color': '#FF2196F3',
  'corner_radius': 8.0,
};

/// Provider for the feature flag service
final featureFlagServiceProvider = Provider<FeatureFlagService>((ref) {
  final service = LocalFeatureFlagService();

  // Set default values
  service.setDefaults(kDefaultFeatureFlags);

  // Initialize the service
  service.init();

  // Setup analytics tracking
  final analytics = ref.watch(analyticsProvider);
  service.addListener(() {
    analytics.logUserAction(
      action: 'feature_flags_updated',
      category: 'config',
    );
  });

  // Dispose the service when the provider is disposed
  ref.onDispose(() {
    // We know it's LocalFeatureFlagService since we created it above
    service.dispose();
  });

  return service;
});

/// Creates a provider for a specific feature flag
Provider<bool> createFeatureFlagProvider(
  String flagKey, {
  bool defaultValue = false,
}) {
  return Provider<bool>((ref) {
    final service = ref.watch(featureFlagServiceProvider);
    return service.getBool(flagKey, defaultValue: defaultValue);
  });
}

/// Helper to create a provider for a specific feature flag
Provider<bool> featureFlagProvider(
  String flagKey, {
  bool defaultValue = false,
}) {
  return Provider<bool>((ref) {
    final service = ref.watch(featureFlagServiceProvider);
    return service.getBool(flagKey, defaultValue: defaultValue);
  });
}

/// Helper to create a provider for a specific string config value
Provider<String> stringConfigProvider(
  String key, {
  required String defaultValue,
}) {
  return Provider<String>((ref) {
    final service = ref.watch(featureFlagServiceProvider);
    return service.getString(key, defaultValue: defaultValue);
  });
}

/// Helper to create a provider for a specific int config value
Provider<int> intConfigProvider(String key, {required int defaultValue}) {
  return Provider<int>((ref) {
    final service = ref.watch(featureFlagServiceProvider);
    return service.getInt(key, defaultValue: defaultValue);
  });
}

/// Helper to create a provider for a specific double config value
Provider<double> doubleConfigProvider(
  String key, {
  required double defaultValue,
}) {
  return Provider<double>((ref) {
    final service = ref.watch(featureFlagServiceProvider);
    return service.getDouble(key, defaultValue: defaultValue);
  });
}

/// Helper to create a provider for a specific color config value
Provider<Color> colorConfigProvider(String key, {required Color defaultValue}) {
  return Provider<Color>((ref) {
    final service = ref.watch(featureFlagServiceProvider);
    return service.getColor(key, defaultValue: defaultValue);
  });
}

/// Widget that only shows its child if a feature flag is enabled
class FeatureFlag extends ConsumerWidget {
  final String featureKey;
  final bool defaultValue;
  final Widget child;
  final Widget? fallback;

  const FeatureFlag({
    Key? key,
    required this.featureKey,
    this.defaultValue = false,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(featureFlagServiceProvider);
    final enabled = service.getBool(featureKey, defaultValue: defaultValue);

    if (enabled) {
      return child;
    } else {
      return fallback ?? const SizedBox.shrink();
    }
  }
}
