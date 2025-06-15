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
final accessibilitySettingsProvider =
    StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>(
      (ref) {
        final service = ref.watch(accessibilityServiceProvider);
        return AccessibilitySettingsNotifier(service);
      },
    );

/// Notifier for accessibility settings
class AccessibilitySettingsNotifier
    extends StateNotifier<AccessibilitySettings> {
  final AccessibilityService _service;
  Function? _unregisterCallback;

  AccessibilitySettingsNotifier(this._service)
    : super(_service.getCurrentSettings()) {
    _unregisterCallback = _service.registerForSettingsChanges(
      _onSettingsChanged,
    );
  }

  void _onSettingsChanged(AccessibilitySettings settings) {
    state = settings;
  }

  @override
  void dispose() {
    _unregisterCallback?.call();
    super.dispose();
  }

  /// Announce a message for screen reader users
  Future<void> announce(String message) async {
    await _service.announce(message);
  }

  /// Get a semantic label for an element
  String getSemanticLabel(String key, [Map<String, String>? args]) {
    return _service.getSemanticLabel(key, args);
  }
}

/// Widget that provides accessibility features to its children
class AccessibilityWrapper extends ConsumerWidget {
  /// The child widget to wrap
  final Widget child;

  /// Create an accessibility wrapper
  const AccessibilityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilitySettingsProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // Apply font scaling if needed
        textScaleFactor: settings.fontScale,
        // Reduce animations if needed
        disableAnimations: settings.isReduceMotionEnabled,
        // Set high contrast if needed
        highContrast: settings.isHighContrastEnabled,
        // Set bold text if needed
        boldText: settings.isBoldTextEnabled,
      ),
      child: child,
    );
  }
}
