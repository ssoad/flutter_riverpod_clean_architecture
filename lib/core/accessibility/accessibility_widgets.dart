import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/accessibility/accessibility_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';

/// Extension methods for accessibility-related Widget functionality
extension AccessibilityWidgetExtensions on Widget {
  /// Wraps this widget with a minimum size to ensure it meets touch target size requirements
  Widget withMinimumTouchTargetSize() {
    return SizedBox(
      width: AppConstants.accessibilityTouchTargetMinSize,
      height: AppConstants.accessibilityTouchTargetMinSize,
      child: Center(child: this),
    );
  }

  /// Adds a semantic label to this widget
  Widget withSemanticLabel(String label) {
    return Semantics(label: label, child: this);
  }

  /// Excludes this widget from semantics if screen reader is active
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Increases the touch target size of this widget without affecting layout
  Widget withIncreasedTouchTarget({double minSize = 48.0}) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.translucent,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
        child: this,
      ),
    );
  }

  /// Wraps this widget with a tooltip accessible to screen readers
  Widget withAccessibleTooltip(String message) {
    return Tooltip(
      message: message,
      showDuration: AppConstants.accessibilityTooltipDuration,
      child: this,
    );
  }

  /// Makes this widget conditionally accessible based on screen reader state
  Widget conditionallyAccessible(
    bool isAccessible, {
    required String accessibleLabel,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(accessibilitySettingsProvider);

        if (settings.isScreenReaderActive && isAccessible) {
          return Semantics(
            label: accessibleLabel,
            excludeSemantics: false,
            child: this,
          );
        }

        return this;
      },
    );
  }
}

/// A button that meets accessibility requirements
class AccessibleButton extends ConsumerWidget {
  /// The child widget
  final Widget child;

  /// The button's semantic label
  final String semanticLabel;

  /// The callback when pressed
  final VoidCallback? onPressed;

  /// Create an accessible button
  const AccessibleButton({
    Key? key,
    required this.child,
    required this.semanticLabel,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: onPressed != null,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: AppConstants.accessibilityTouchTargetMinSize,
            minHeight: AppConstants.accessibilityTouchTargetMinSize,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// A text field that meets accessibility requirements
class AccessibleTextField extends StatelessWidget {
  /// The controller for the text field
  final TextEditingController? controller;

  /// The text field's semantic label
  final String semanticLabel;

  /// The hint text
  final String? hintText;

  /// The error text
  final String? errorText;

  /// The callback when the text changes
  final void Function(String)? onChanged;

  /// Whether the field is obscured
  final bool obscureText;

  /// Create an accessible text field
  const AccessibleTextField({
    Key? key,
    this.controller,
    required this.semanticLabel,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: semanticLabel,
      hint: hintText,
      value: controller?.text,
      enabled: true,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: semanticLabel,
          hintText: hintText,
          errorText: errorText,
        ),
      ),
    );
  }
}

/// A switch that meets accessibility requirements
class AccessibleSwitch extends StatelessWidget {
  /// The switch's semantic label
  final String semanticLabel;

  /// Whether the switch is on
  final bool value;

  /// The callback when the switch is toggled
  final ValueChanged<bool> onChanged;

  /// Create an accessible switch
  const AccessibleSwitch({
    Key? key,
    required this.semanticLabel,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      toggled: value,
      child: Switch(value: value, onChanged: onChanged),
    );
  }
}
