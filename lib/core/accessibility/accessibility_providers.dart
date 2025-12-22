import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/accessibility/accessibility_service.dart';

/// Provider for the accessibility service
final accessibilityServiceProvider = Provider<AccessibilityService>((ref) {
  final service = FlutterAccessibilityService();

  // Initialize the service
  service.init();

  // Dispose when the provider is destroyed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for the current accessibility settings
/// Provider for the current accessibility settings
final accessibilitySettingsProvider =
    NotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>(
      AccessibilitySettingsNotifier.new,
    );

/// Notifier for accessibility settings
class AccessibilitySettingsNotifier extends Notifier<AccessibilitySettings> {
  Function? _unregisterCallback;

  @override
  AccessibilitySettings build() {
    final service = ref.watch(accessibilityServiceProvider);

    // Register for changes
    _unregisterCallback = service.registerForSettingsChanges(
      _onSettingsChanged,
    );

    // Unregister on dispose
    ref.onDispose(() {
      _unregisterCallback?.call();
    });

    return service.getCurrentSettings();
  }

  void _onSettingsChanged(AccessibilitySettings settings) {
    state = settings;
  }

  /// Announce a message for screen reader users
  Future<void> announce(String message) async {
    final service = ref.read(accessibilityServiceProvider);
    await service.announce(message);
  }

  /// Get a semantic label for an element
  String getSemanticLabel(String key, [Map<String, String>? args]) {
    final service = ref.read(accessibilityServiceProvider);
    return service.getSemanticLabel(key, args);
  }
}

/// Widget that provides accessibility features to its children
class AccessibilityWrapper extends ConsumerWidget {
  /// The child widget to wrap
  final Widget child;

  /// Create an accessibility wrapper
  const AccessibilityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilitySettingsProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // Apply font scaling if needed
        disableAnimations: settings.isReduceMotionEnabled,
        // Set high contrast if needed
        highContrast: settings.isHighContrastEnabled,
        textScaler: TextScaler.linear(settings.fontScale),
        // Set bold text if needed
        boldText: settings.isBoldTextEnabled,
      ),
      child: child,
    );
  }
}
