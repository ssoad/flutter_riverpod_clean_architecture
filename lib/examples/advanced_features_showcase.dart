import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/biometric_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/feature_flags/feature_flag_providers.dart';

import 'package:flutter_riverpod_clean_architecture/core/images/advanced_image.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/image_transformer.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/shimmer_placeholder.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/svg_renderer.dart';
import 'package:flutter_riverpod_clean_architecture/core/logging/logger_provider.dart';
import 'package:flutter_riverpod_clean_architecture/core/notifications/notification_providers.dart';

import '../core/feature_flags/local_feature_flag_service.dart';

/// A screen that showcases the advanced features of the architecture template
class AdvancedFeaturesShowcase extends ConsumerStatefulWidget {
  const AdvancedFeaturesShowcase({Key? key}) : super(key: key);

  @override
  ConsumerState<AdvancedFeaturesShowcase> createState() =>
      _AdvancedFeaturesShowcaseState();
}

class _AdvancedFeaturesShowcaseState
    extends ConsumerState<AdvancedFeaturesShowcase>
    with LoggerStateMixin {
  @override
  void initState() {
    super.initState();
    // Log initialization with performance tracking
    logger.timeSync('Screen initialization', () {
      // Initialize any resources
      logger.i('Advanced features showcase initialized');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access feature flags
    final showAnalytics = ref.watch(
      featureFlagProvider('enable_analytics', defaultValue: true),
    );
    final showBiometrics = ref.watch(
      featureFlagProvider('enable_biometric_login', defaultValue: true),
    );
    final primaryColor = ref.watch(
      colorConfigProvider('primary_color', defaultValue: Colors.blue),
    );

    // Access analytics
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Features'),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Feature Flags'),
          _buildFeatureFlags(),

          _buildSectionHeader('Analytics'),
          if (showAnalytics) _buildAnalytics(analytics),

          _buildSectionHeader('Biometric Authentication'),
          if (showBiometrics) _buildBiometrics(),

          _buildSectionHeader('Notifications'),
          _buildNotifications(),

          _buildSectionHeader('Advanced Images'),
          _buildAdvancedImages(),

          _buildSectionHeader('Structured Logging'),
          _buildLogging(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFeatureFlags() {
    final service = ref.watch(featureFlagServiceProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Toggle features at runtime:'),
            const SizedBox(height: 16),
            _buildFeatureSwitch('Analytics', 'enable_analytics'),
            _buildFeatureSwitch(
              'Push Notifications',
              'enable_push_notifications',
            ),
            _buildFeatureSwitch('Biometric Login', 'enable_biometric_login'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                service.fetchAndActivate().then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Remote configs updated')),
                  );
                });
              },
              child: const Text('Refresh Feature Flags'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSwitch(String label, String featureKey) {
    final service = ref.watch(featureFlagServiceProvider);
    final isEnabled = service.getBool(featureKey, defaultValue: true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(
          value: isEnabled,
          onChanged: (value) {
            if (service is LocalFeatureFlagService) {
              service.setValue(featureKey, value);
              setState(() {});
            }
          },
        ),
      ],
    );
  }

  Widget _buildAnalytics(Analytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Track events and user actions:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    analytics.logScreenView('AdvancedFeaturesShowcase');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Screen view event logged')),
                    );
                  },
                  child: const Text('Log Screen View'),
                ),
                ElevatedButton(
                  onPressed: () {
                    analytics.logUserAction(
                      action: 'button_tap',
                      category: 'engagement',
                      label: 'analytics_demo',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User action event logged')),
                    );
                  },
                  child: const Text('Log User Action'),
                ),
                ElevatedButton(
                  onPressed: () {
                    analytics.logError(
                      errorType: 'demo_error',
                      message: 'This is a test error',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error event logged')),
                    );
                  },
                  child: const Text('Log Error'),
                ),
                ElevatedButton(
                  onPressed: () {
                    analytics.logPerformance(
                      name: 'demo_operation',
                      value: 123.45,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Performance event logged')),
                    );
                  },
                  child: const Text('Log Performance'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometrics() {
    final biometricAuth = ref.watch(biometricAuthControllerProvider);
    final biometricsAvailable = ref.watch(biometricsAvailableProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Authenticate with biometrics:'),
            const SizedBox(height: 16),
            biometricsAvailable.when(
              data: (isAvailable) {
                if (!isAvailable) {
                  return const Text('Biometrics not available on this device');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: ${biometricAuth.isAuthenticated ? "Authenticated" : "Not authenticated"}',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await biometricAuth.authenticate(
                          reason:
                              'Please authenticate to access secure features',
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Authentication result: $result'),
                          ),
                        );
                      },
                      child: const Text('Authenticate'),
                    ),
                    if (biometricAuth.isAuthenticated)
                      TextButton(
                        onPressed: () {
                          biometricAuth.logout();
                          setState(() {});
                        },
                        child: const Text('Log Out'),
                      ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error:
                  (_, __) =>
                      const Text('Error checking biometrics availability'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifications() {
    final service = ref.watch(notificationServiceProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage push notifications:'),
            const SizedBox(height: 16),
            notificationsEnabled.when(
              data: (isEnabled) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications: ${isEnabled ? "Enabled" : "Disabled"}',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await service.requestPermission();
                            ref.invalidate(notificationsEnabledProvider);
                          },
                          child: const Text('Request Permission'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await service.showLocalNotification(
                              id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
                              title: 'Sample Notification',
                              body:
                                  'This is a test notification from the showcase',
                              action: '/showcase',
                              channel: 'demo',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification sent'),
                              ),
                            );
                          },
                          child: const Text('Send Test Notification'),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error:
                  (_, __) =>
                      const Text('Error checking notification permissions'),
            ),
          ],
        ),
      ),
    );
  }

  // Image effect controls state
  final Map<ImageEffectType, double> _effectsIntensity = {
    ImageEffectType.none: 1.0,
    ImageEffectType.grayscale: 0.0,
    ImageEffectType.sepia: 0.0,
    ImageEffectType.blur: 0.0,
  };
  ImageEffectType _selectedEffect = ImageEffectType.none;

  Widget _buildAdvancedImages() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Advanced image handling:'),
            const SizedBox(height: 16),

            // Top row with placeholders
            Text(
              'Loading placeholders:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ShimmerPlaceholder(
                      width: 100,
                      height: 100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ShimmerPlaceholder(
                      width: 100,
                      height: 100,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ImageCardSkeleton(
                      width: 100,
                      height: 100,
                      showTitle: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Advanced image loading:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: AdvancedImage(
                      imageUrl: 'https://picsum.photos/400/200?random=1',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: ShimmerPlaceholder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ImageTransformer(
                      effect: ImageEffectConfig(
                        effectType: _selectedEffect,
                        intensity: _effectsIntensity[_selectedEffect] ?? 1.0,
                      ),
                      child: AdvancedImage(
                        imageUrl: 'https://picsum.photos/400/200?random=2',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: ShimmerPlaceholder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SvgImage.network(
                      'https://picsum.photos/200', // Normally this would be an SVG URL
                      width: 200,
                      height: 200,
                      placeholder: ShimmerPlaceholder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Effect controls
            const SizedBox(height: 16),
            Text(
              'Image effects:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildEffectChip(ImageEffectType.none, 'Normal'),
                _buildEffectChip(ImageEffectType.grayscale, 'Grayscale'),
                _buildEffectChip(ImageEffectType.sepia, 'Sepia'),
                _buildEffectChip(ImageEffectType.blur, 'Blur'),
              ],
            ),

            // Effect intensity slider
            if (_selectedEffect != ImageEffectType.none) ...[
              const SizedBox(height: 8),
              Slider(
                value: _effectsIntensity[_selectedEffect] ?? 0,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label:
                    '${(_effectsIntensity[_selectedEffect] ?? 0.0).toStringAsFixed(1)}',
                onChanged: (value) {
                  setState(() {
                    _effectsIntensity[_selectedEffect] = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEffectChip(ImageEffectType effectType, String label) {
    final isSelected = _selectedEffect == effectType;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedEffect = selected ? effectType : ImageEffectType.none;
        });
      },
      backgroundColor: isSelected ? null : Colors.grey.shade200,
    );
  }

  Widget _buildLogging() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log events with different levels:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    logger.d('Debug log message');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debug log generated')),
                    );
                  },
                  child: const Text('Debug Log'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger.i('Info log message', data: {'source': 'showcase'});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Info log generated')),
                    );
                  },
                  child: const Text('Info Log'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger.w('Warning log message');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Warning log generated')),
                    );
                  },
                  child: const Text('Warning Log'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger.e(
                      'Error log message',
                      error: Exception('Test error'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error log generated')),
                    );
                  },
                  child: const Text('Error Log'),
                ),
                ElevatedButton(
                  onPressed: () {
                    logger.timeSync('Demo operation', () {
                      // Simulate some work
                      int sum = 0;
                      for (int i = 0; i < 1000000; i++) {
                        sum += i;
                      }
                      return sum;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Performance log generated'),
                      ),
                    );
                  },
                  child: const Text('Performance Log'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
