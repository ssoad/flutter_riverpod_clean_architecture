# Accessibility Guide

This guide explains how to use the accessibility features in the Flutter Riverpod Clean Architecture template to make your app more inclusive.

## Table of Contents

- [Introduction](#introduction)
- [Key Components](#key-components)
- [Using Accessibility Features](#using-accessibility-features)
- [Semantic Labels](#semantic-labels)
- [Screen Reader Support](#screen-reader-support)
- [Touch Targets](#touch-targets)
- [High Contrast and Dynamic Text](#high-contrast-and-dynamic-text)
- [Best Practices](#best-practices)

## Introduction

Accessibility is essential for ensuring your app can be used by everyone, including people with disabilities. The Flutter Riverpod Clean Architecture template includes comprehensive accessibility support to help you build inclusive applications.

## Key Components

The accessibility module consists of several key components:

- `AccessibilityService`: Interface for accessing device accessibility settings
- `FlutterAccessibilityService`: Implementation of the accessibility service
- `AccessibilitySettings`: Class representing current accessibility settings
- `AccessibilityWrapper`: Widget that applies accessibility settings to child widgets
- Extension methods for adding accessibility features to widgets
- Accessible widgets (`AccessibleButton`, `AccessibleTextField`, etc.)

## Using Accessibility Features

### Wrapping Your App

The application is already wrapped with the `AccessibilityWrapper` in `main.dart`:

```dart
return AccessibilityWrapper(
  child: MaterialApp.router(
    // App configuration
  ),
);
```

This automatically applies device accessibility settings (font scaling, animations, etc.) to your app.

### Adding Accessibility to Widgets

Use the extension methods to add accessibility features to your widgets:

```dart
// Increase touch target size
myButton.withMinimumTouchTargetSize()

// Add semantic labels
myImage.withSemanticLabel('Profile picture of John Doe')

// Add accessible tooltips
myIcon.withAccessibleTooltip('Delete item')

// Exclude decorative elements from screen readers
decorativeElement.excludeFromSemantics()
```

### Using Accessible Widgets

Use the pre-built accessible widgets for common UI components:

```dart
AccessibleButton(
  onPressed: () => doSomething(),
  semanticLabel: 'Save changes',
  child: Text('Save'),
)

AccessibleTextField(
  controller: myController,
  semanticLabel: 'Email address',
  hintText: 'Enter your email',
)

AccessibleSwitch(
  value: isEnabled,
  onChanged: (value) => setEnabled(value),
  semanticLabel: 'Enable notifications',
)
```

## Semantic Labels

Semantic labels provide context for screen reader users. Always include clear, descriptive labels:

```dart
Image.asset(
  'assets/images/logo.png',
  semanticLabel: 'Company logo',
)

IconButton(
  icon: Icon(Icons.delete),
  onPressed: () => deleteItem(),
  tooltip: 'Delete item', // This becomes the semantic label
)
```

## Screen Reader Support

### Announcing Changes

Use the `announce` method to inform screen reader users of important changes:

```dart
final accessibilityNotifier = ref.read(accessibilitySettingsProvider.notifier);
accessibilityNotifier.announce('Order successfully placed');
```

### Custom Semantics

For complex widgets, use the `Semantics` widget to provide detailed information:

```dart
Semantics(
  label: 'Progress bar',
  value: '$progressPercent%',
  child: LinearProgressIndicator(value: progress),
)
```

## Touch Targets

Ensure all interactive elements are large enough to be easily tapped:

```dart
// Using the extension method
IconButton(/*...*/).withMinimumTouchTargetSize()

// Or directly
SizedBox(
  width: AppConstants.accessibilityTouchTargetMinSize,
  height: AppConstants.accessibilityTouchTargetMinSize,
  child: Center(child: IconButton(/*...*/)),
)
```

## High Contrast and Dynamic Text

The `AccessibilityWrapper` automatically handles:

- Text scaling based on user preferences
- High contrast mode
- Bold text
- Reduced motion

You can access these settings directly:

```dart
final accessibilitySettings = ref.watch(accessibilitySettingsProvider);

if (accessibilitySettings.isHighContrastEnabled) {
  // Use high contrast colors
}

if (accessibilitySettings.isReduceMotionEnabled) {
  // Skip animations
}
```

## Best Practices

1. **Test with screen readers**: Regularly test your app with TalkBack (Android) and VoiceOver (iOS)
2. **Use semantic labels**: Add descriptive labels to all interactive elements
3. **Provide text alternatives**: Include alt text for images and icons
4. **Ensure sufficient contrast**: Use colors with good contrast ratios
5. **Support keyboard navigation**: Make sure all features are accessible via keyboard
6. **Group related elements**: Use `MergeSemantics` to group related elements
7. **Test font scaling**: Ensure your UI works with different text sizes
8. **Avoid time-based interactions**: Don't require quick reactions from users

Remember that accessibility benefits everyone, not just users with disabilities!
