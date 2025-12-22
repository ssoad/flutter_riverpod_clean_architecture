import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Interface for accessibility services
abstract class AccessibilityService {
  /// Check if screen reader is active
  Future<bool> isScreenReaderActive();

  /// Get current accessibility settings
  AccessibilitySettings getCurrentSettings();

  /// Announce a message for screen reader users
  Future<void> announce(String message);

  /// Initialize the service
  Future<void> init();

  /// Clean up resources when no longer needed
  Future<void> dispose();

  /// Register for accessibility settings changes
  Function registerForSettingsChanges(Function(AccessibilitySettings) callback);

  /// Get semantic label for an element (with localization if possible)
  String getSemanticLabel(String key, Map<String, String>? args);
}

/// Accessibility settings for the app
class AccessibilitySettings {
  /// Whether a screen reader is active (e.g., VoiceOver, TalkBack)
  final bool isScreenReaderActive;

  /// Whether high contrast mode is enabled
  final bool isHighContrastEnabled;

  /// Whether bold text is enabled
  final bool isBoldTextEnabled;

  /// Whether reduce motion is enabled
  final bool isReduceMotionEnabled;

  /// Font scale factor
  final double fontScale;

  /// Create accessibility settings
  const AccessibilitySettings({
    this.isScreenReaderActive = false,
    this.isHighContrastEnabled = false,
    this.isBoldTextEnabled = false,
    this.isReduceMotionEnabled = false,
    this.fontScale = 1.0,
  });

  /// Create a copy with fields replaced
  AccessibilitySettings copyWith({
    bool? isScreenReaderActive,
    bool? isHighContrastEnabled,
    bool? isBoldTextEnabled,
    bool? isReduceMotionEnabled,
    double? fontScale,
  }) {
    return AccessibilitySettings(
      isScreenReaderActive: isScreenReaderActive ?? this.isScreenReaderActive,
      isHighContrastEnabled:
          isHighContrastEnabled ?? this.isHighContrastEnabled,
      isBoldTextEnabled: isBoldTextEnabled ?? this.isBoldTextEnabled,
      isReduceMotionEnabled:
          isReduceMotionEnabled ?? this.isReduceMotionEnabled,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}

/// Flutter implementation of accessibility service
class FlutterAccessibilityService implements AccessibilityService {
  final FlutterTts _flutterTts = FlutterTts();
  AccessibilitySettings _currentSettings = const AccessibilitySettings();
  final List<Function(AccessibilitySettings)> _listeners = [];

  @override
  Future<void> init() async {
    // Initialize TTS
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);

    // Listen for semantics changes using SemanticsService
    SemanticsBinding.instance.addSemanticsEnabledListener(_updateSettings);

    // Initial settings update
    _updateSettings();

    debugPrint('📱 Accessibility service initialized');
  }

  void _updateSettings() {
    final mediaQueryData = MediaQueryData.fromView(
      WidgetsBinding.instance.window,
    );

    _currentSettings = AccessibilitySettings(
      isScreenReaderActive: SemanticsBinding.instance.semanticsEnabled,
      isHighContrastEnabled: mediaQueryData.highContrast,
      isBoldTextEnabled: mediaQueryData.boldText,
      isReduceMotionEnabled: mediaQueryData.disableAnimations,
      fontScale: mediaQueryData.textScaleFactor,
    );

    // Notify all listeners
    for (final listener in _listeners) {
      listener(_currentSettings);
    }
  }

  @override
  Future<bool> isScreenReaderActive() async {
    return SemanticsBinding.instance.semanticsEnabled;
  }

  @override
  AccessibilitySettings getCurrentSettings() {
    return _currentSettings;
  }

  @override
  Future<void> announce(String message) async {
    if (await isScreenReaderActive()) {
      SemanticsService.announce(message, TextDirection.ltr);

      // Optionally, use TTS for platforms where semantics announce isn't well supported
      try {
        await _flutterTts.speak(message);
      } catch (e) {
        debugPrint('📱 Error speaking message: $e');
      }
    }
  }

  @override
  Future<void> dispose() async {
    SemanticsBinding.instance.removeSemanticsEnabledListener(_updateSettings);
    await _flutterTts.stop();
  }

  @override
  Function registerForSettingsChanges(
    Function(AccessibilitySettings) callback,
  ) {
    _listeners.add(callback);

    // Return function to unregister
    return () => _listeners.remove(callback);
  }

  @override
  String getSemanticLabel(String key, Map<String, String>? args) {
    // In a real app, this would use the localization system
    // This is a simple implementation for demo purposes
    return key;
  }
}
