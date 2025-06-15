import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/accessibility/accessibility_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/accessibility/accessibility_widgets.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_providers.dart';
// Biometrics demo is imported directly
import 'package:flutter_riverpod_clean_architecture/examples/biometrics_demo.dart';
import 'package:flutter_riverpod_clean_architecture/core/feature_flags/feature_flag_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/advanced_image.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/image_transformer.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/shimmer_placeholder.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/svg_renderer.dart';
import 'package:flutter_riverpod_clean_architecture/core/logging/logger_provider.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/offline_sync_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/offline_sync_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/notifications/notification_providers.dart';
// Theme handling is managed through feature flags
import 'package:flutter_riverpod_clean_architecture/core/updates/update_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/updates/update_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_review_providers.dart';

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
  // Image effect controls state
  final Map<ImageEffectType, double> _effectsIntensity = {
    ImageEffectType.none: 1.0,
    ImageEffectType.grayscale: 0.0,
    ImageEffectType.sepia: 0.0,
    ImageEffectType.blur: 0.0,
  };
  ImageEffectType _selectedEffect = ImageEffectType.none;

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

          _buildSectionHeader('Accessibility'),
          _buildAccessibility(),

          _buildSectionHeader('App Update Flow'),
          _buildUpdateFlow(),

          _buildSectionHeader('Offline-First Architecture'),
          _buildOfflineSync(),

          _buildSectionHeader('App Review System'),
          _buildAppReview(),
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
    return const BiometricsDemo();
  }

  Widget _buildNotifications() {
    final service = ref.watch(notificationServiceProvider);
    final notificationsEnabledAsync = ref.watch(notificationsEnabledProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage push notifications:'),
            const SizedBox(height: 16),
            notificationsEnabledAsync.when(
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

            // Advanced image loading
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

  Widget _buildAccessibility() {
    final accessibilitySettings = ref.watch(accessibilitySettingsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Make your app usable by everyone:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Screen Reader Active'),
              subtitle: Text(
                accessibilitySettings.isScreenReaderActive ? 'Yes' : 'No',
              ),
              leading: Icon(
                accessibilitySettings.isScreenReaderActive
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            ),
            ListTile(
              title: const Text('High Contrast'),
              subtitle: Text(
                accessibilitySettings.isHighContrastEnabled
                    ? 'Enabled'
                    : 'Disabled',
              ),
              leading: Icon(
                accessibilitySettings.isHighContrastEnabled
                    ? Icons.contrast
                    : Icons.contrast_outlined,
              ),
            ),
            ListTile(
              title: const Text('Font Scale'),
              subtitle: Text('${accessibilitySettings.fontScale}x'),
              leading: const Icon(Icons.format_size),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AccessibleButton(
                  semanticLabel: 'Announce to screen readers',
                  onPressed: () {
                    final notifier = ref.read(
                      accessibilitySettingsProvider.notifier,
                    );
                    notifier.announce('This is a screen reader announcement');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message announced to screen readers'),
                      ),
                    );
                  },
                  child: const Text('Announce Message'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateFlow() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage app updates with customizable flows:'),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                final updateCheck = ref.watch(updateCheckProvider);

                return ListTile(
                  title: const Text('Update Status'),
                  subtitle: Text(
                    updateCheck.when(
                      data: (result) => result.toString().split('.').last,
                      loading: () => 'Checking...',
                      error: (_, __) => 'Error checking for updates',
                    ),
                  ),
                  leading: updateCheck.when(
                    data: (result) {
                      switch (result) {
                        case UpdateCheckResult.upToDate:
                          return const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          );
                        case UpdateCheckResult.updateAvailable:
                          return const Icon(Icons.info, color: Colors.blue);
                        case UpdateCheckResult.criticalUpdateRequired:
                          return const Icon(Icons.warning, color: Colors.red);
                        case UpdateCheckResult.checkFailed:
                          return const Icon(
                            Icons.error_outline,
                            color: Colors.orange,
                          );
                      }
                    },
                    loading:
                        () => const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    error:
                        (_, __) => const Icon(Icons.error, color: Colors.red),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final updateService = ref.read(updateServiceProvider);
                    updateService.checkForUpdates().then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Checking for updates...'),
                        ),
                      );
                      ref.invalidate(updateCheckProvider);
                    });
                  },
                  child: const Text('Check for Updates'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updateService = ref.read(updateServiceProvider);
                    updateService.getUpdateInfo().then((updateInfo) {
                      if (updateInfo != null && context.mounted) {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  updateInfo.isCritical
                                      ? 'Critical Update Available'
                                      : 'Update Available',
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'New version: ${updateInfo.latestVersion}',
                                    ),
                                    if (updateInfo.releaseNotes != null) ...[
                                      const SizedBox(height: 8),
                                      Text(updateInfo.releaseNotes!),
                                    ],
                                  ],
                                ),
                                actions: [
                                  if (!updateInfo.isCritical)
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Later'),
                                    ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      // Open the app store
                                      updateService.openUpdateUrl();
                                    },
                                    child: const Text('Update Now'),
                                  ),
                                ],
                              ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No update info available'),
                          ),
                        );
                      }
                    });
                  },
                  child: const Text('Show Update Dialog'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineSync() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Keep working even when offline:'),
            const SizedBox(height: 16),
            const OfflineStatusIndicator(),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                final pendingChanges = ref.watch(pendingChangesProvider);

                return pendingChanges.when(
                  data: (changes) {
                    if (changes.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No pending changes'),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending Changes: ${changes.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        for (final change in changes)
                          ListTile(
                            dense: true,
                            title: Text(
                              '${change.entityType} ${change.operationType.toString().split('.').last}',
                            ),
                            subtitle: Text(
                              'Status: ${change.status.toString().split('.').last}',
                            ),
                            leading: _getOperationIcon(change.operationType),
                            trailing: _getStatusIcon(change.status),
                          ),
                      ],
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error loading changes'),
                );
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(offlineSyncServiceProvider)
                        .queueChange(
                          entityType: 'testEntity',
                          operationType: OfflineOperationType.create,
                          data: {
                            'name': 'Test Entity',
                            'createdAt': DateTime.now().toIso8601String(),
                          },
                        )
                        .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test operation created'),
                            ),
                          );
                          ref.invalidate(pendingChangesProvider);
                        });
                  },
                  child: const Text('Create Test Change'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(offlineSyncServiceProvider).syncChanges().then((
                      _,
                    ) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sync triggered')),
                      );
                      ref.invalidate(pendingChangesProvider);
                    });
                  },
                  child: const Text('Sync Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getOperationIcon(OfflineOperationType type) {
    switch (type) {
      case OfflineOperationType.create:
        return const Icon(Icons.add_circle, color: Colors.green);
      case OfflineOperationType.update:
        return const Icon(Icons.edit, color: Colors.blue);
      case OfflineOperationType.delete:
        return const Icon(Icons.delete, color: Colors.red);
      case OfflineOperationType.custom:
        return const Icon(Icons.code, color: Colors.purple);
    }
  }

  Widget _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return const Icon(Icons.pending, color: Colors.orange);
      case SyncStatus.syncing:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.synced:
        return const Icon(Icons.check_circle, color: Colors.green);
      case SyncStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case SyncStatus.conflict:
        return const Icon(Icons.warning, color: Colors.deepOrange);
      case SyncStatus.canceled:
        return const Icon(Icons.cancel, color: Colors.grey);
    }
  }

  Widget _buildAppReview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Get feedback and ratings from your users:'),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final shouldRequestReview = ref.watch(
                  shouldRequestReviewProvider,
                );
                return ListTile(
                  title: const Text('Review Status'),
                  subtitle: Text(
                    shouldRequestReview.when(
                      data:
                          (shouldRequest) =>
                              shouldRequest
                                  ? 'Ready to request review'
                                  : 'Not ready for review yet',
                      loading: () => 'Checking...',
                      error: (_, __) => 'Error checking review status',
                    ),
                  ),
                  leading: shouldRequestReview.when(
                    data:
                        (shouldRequest) =>
                            shouldRequest
                                ? const Icon(Icons.star, color: Colors.amber)
                                : const Icon(Icons.star_border),
                    loading:
                        () => const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    error:
                        (_, __) => const Icon(Icons.error, color: Colors.red),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final reviewService = ref.read(appReviewServiceProvider);
                    reviewService.recordSignificantAction().then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Significant action recorded'),
                        ),
                      );
                      ref.invalidate(shouldRequestReviewProvider);
                    });
                  },
                  child: const Text('Record Action'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final reviewService = ref.read(appReviewServiceProvider);
                    reviewService.recordAppSession().then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('App session recorded')),
                      );
                      ref.invalidate(shouldRequestReviewProvider);
                    });
                  },
                  child: const Text('Record Session'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final reviewService = ref.read(appReviewServiceProvider);
                    reviewService
                        .showFeedbackForm(
                          context: context,
                          title: 'Enjoying the App?',
                          message:
                              'We\'d love to hear your feedback! Please let us know what you think.',
                        )
                        .then((hasFeedback) {
                          if (hasFeedback) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thank you for your feedback!'),
                              ),
                            );
                          }
                        });
                  },
                  child: const Text('Show Feedback Form'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
