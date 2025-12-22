import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Types of image effects that can be applied to an image
enum ImageEffectType {
  /// No effect (original image)
  none,

  /// Grayscale effect
  grayscale,

  /// Sepia tone effect
  sepia,

  /// Inverted colors effect
  invert,

  /// Blur effect
  blur,

  /// Overlay color
  overlay,

  /// Brightness adjustment
  brightness,

  /// Contrast adjustment
  contrast,

  /// Saturation adjustment
  saturation,
}

/// Configuration for image effects
class ImageEffectConfig {
  /// The type of effect to apply
  final ImageEffectType effectType;

  /// The intensity of the effect (0.0 to 1.0)
  final double intensity;

  /// Color used for overlay effects
  final Color? overlayColor;

  /// Create an image effect configuration
  const ImageEffectConfig({
    this.effectType = ImageEffectType.none,
    this.intensity = 1.0,
    this.overlayColor,
  });

  /// Creates a copy of this configuration with the given fields replaced
  ImageEffectConfig copyWith({
    ImageEffectType? effectType,
    double? intensity,
    Color? overlayColor,
  }) {
    return ImageEffectConfig(
      effectType: effectType ?? this.effectType,
      intensity: intensity ?? this.intensity,
      overlayColor: overlayColor ?? this.overlayColor,
    );
  }
}

/// A widget that applies visual effects to its child
class ImageTransformer extends StatelessWidget {
  /// The widget to apply effects to
  final Widget child;

  /// The effect configuration
  final ImageEffectConfig effect;

  /// Create an image transformer
  const ImageTransformer({
    super.key,
    required this.child,
    required this.effect,
  });

  @override
  Widget build(BuildContext context) {
    switch (effect.effectType) {
      case ImageEffectType.none:
        return child;

      case ImageEffectType.grayscale:
        return ColorFiltered(
          colorFilter: ColorFilter.matrix(
            _getGrayscaleMatrix(effect.intensity),
          ),
          child: child,
        );

      case ImageEffectType.sepia:
        return ColorFiltered(
          colorFilter: ColorFilter.matrix(_getSepiaMatrix(effect.intensity)),
          child: child,
        );

      case ImageEffectType.invert:
        return ColorFiltered(
          colorFilter: ColorFilter.matrix(_getInvertMatrix(effect.intensity)),
          child: child,
        );

      case ImageEffectType.blur:
        if (effect.intensity <= 0) {
          return child; // No effect
        }
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: effect.intensity * 10.0,
            sigmaY: effect.intensity * 10.0,
          ),
          child: child,
        );

      case ImageEffectType.overlay:
        if (effect.overlayColor == null || effect.intensity <= 0) {
          return child;
        }
        return Stack(
          children: [
            child,
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  effect.overlayColor!.withValues(alpha: effect.intensity),
                  BlendMode.srcOver,
                ),
                child: Container(color: Colors.white),
              ),
            ),
          ],
        );

      case ImageEffectType.brightness:
        return ColorFiltered(
          colorFilter: ColorFilter.matrix(
            _getBrightnessMatrix(effect.intensity),
          ),
          child: child,
        );

      case ImageEffectType.contrast:
        return ColorFiltered(
          colorFilter: ColorFilter.matrix(_getContrastMatrix(effect.intensity)),
          child: child,
        );

      case ImageEffectType.saturation:
        return ColorFiltered(
          colorFilter: ColorFilter.matrix(
            _getSaturationMatrix(effect.intensity),
          ),
          child: child,
        );
    }
  }

  // Color matrix for grayscale effect
  List<double> _getGrayscaleMatrix(double intensity) {
    final double i = 1.0 - intensity;
    final double r = 0.2126 * intensity;
    final double g = 0.7152 * intensity;
    final double b = 0.0722 * intensity;

    return [
      i + r,
      g,
      b,
      0,
      0,
      r,
      i + g,
      b,
      0,
      0,
      r,
      g,
      i + b,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  // Color matrix for sepia effect
  List<double> _getSepiaMatrix(double intensity) {
    final double i = 1.0 - intensity;

    return [
      0.393 * intensity + i,
      0.769 * intensity,
      0.189 * intensity,
      0,
      0,
      0.349 * intensity,
      0.686 * intensity + i,
      0.168 * intensity,
      0,
      0,
      0.272 * intensity,
      0.534 * intensity,
      0.131 * intensity + i,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  // Color matrix for invert effect
  List<double> _getInvertMatrix(double intensity) {
    final double i = 1.0 - intensity;

    return [
      i - intensity,
      0,
      0,
      0,
      intensity * 255,
      0,
      i - intensity,
      0,
      0,
      intensity * 255,
      0,
      0,
      i - intensity,
      0,
      intensity * 255,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  // Color matrix for brightness effect
  List<double> _getBrightnessMatrix(double intensity) {
    // Map 0-1 to -1 to 1 range
    final adjustedIntensity = (intensity * 2.0) - 1.0;

    return [
      1,
      0,
      0,
      0,
      adjustedIntensity * 255,
      0,
      1,
      0,
      0,
      adjustedIntensity * 255,
      0,
      0,
      1,
      0,
      adjustedIntensity * 255,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  // Color matrix for contrast effect
  List<double> _getContrastMatrix(double intensity) {
    // Map 0-1 to 0-2 range
    final adjustedIntensity = intensity * 2.0;
    final t = (1.0 - adjustedIntensity) / 2.0 * 255;

    return [
      adjustedIntensity,
      0,
      0,
      0,
      t,
      0,
      adjustedIntensity,
      0,
      0,
      t,
      0,
      0,
      adjustedIntensity,
      0,
      t,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  // Color matrix for saturation effect
  List<double> _getSaturationMatrix(double intensity) {
    // Map 0-1 to 0-2 range
    final adjustedIntensity = intensity * 2.0;

    final double r = 0.2126 * (1 - adjustedIntensity);
    final double g = 0.7152 * (1 - adjustedIntensity);
    final double b = 0.0722 * (1 - adjustedIntensity);

    return [
      r + adjustedIntensity,
      g,
      b,
      0,
      0,
      r,
      g + adjustedIntensity,
      b,
      0,
      0,
      r,
      g,
      b + adjustedIntensity,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}

/// A widget that applies visual effects to an image
class TransformedImage extends ConsumerWidget {
  /// The image widget to apply effects to
  final Widget child;

  /// The effect configuration provider
  final Provider<ImageEffectConfig> effectProvider;

  /// Create a transformed image
  const TransformedImage({
    super.key,
    required this.child,
    required this.effectProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effect = ref.watch(effectProvider);

    return ImageTransformer(effect: effect, child: child);
  }
}
