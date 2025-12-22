import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';

/// Service for handling language-specific assets in the application
class LocalizedAssetService {
  /// Get the image path for the current locale
  /// Falls back to English if the locale-specific asset doesn't exist
  static String getLocalizedImagePath(BuildContext context, String imageName) {
    final locale = Localizations.localeOf(context);
    return 'assets/images/${locale.languageCode}/$imageName';
  }

  /// Get the image path for a specific language
  /// Falls back to English if the language-specific asset doesn't exist
  static String getImagePathForLanguage(String languageCode, String imageName) {
    return 'assets/images/$languageCode/$imageName';
  }

  /// Get the fallback image path (usually English)
  static String getFallbackImagePath(String imageName) {
    return 'assets/images/en/$imageName';
  }

  /// Get the common image path (not language-specific)
  static String getCommonImagePath(String imageName) {
    return 'assets/images/$imageName';
  }
}

/// A widget that displays a localized image
/// Falls back to default language if the localized version doesn't exist
class LocalizedImage extends ConsumerWidget {
  final String imageName;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final bool useCommonPath;

  const LocalizedImage({
    super.key,
    required this.imageName,
    this.width,
    this.height,
    this.fit,
    this.color,
    this.useCommonPath = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(persistentLocaleProvider);

    return Image.asset(
      useCommonPath
          ? LocalizedAssetService.getCommonImagePath(imageName)
          : LocalizedAssetService.getImagePathForLanguage(
              locale.languageCode,
              imageName,
            ),
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        // If the localized image fails to load, try the fallback
        return Image.asset(
          LocalizedAssetService.getFallbackImagePath(imageName),
          width: width,
          height: height,
          fit: fit,
          color: color,
          errorBuilder: (context, error, stackTrace) {
            // If even the fallback fails, use a placeholder
            return Container(
              width: width,
              height: height,
              color: Colors.grey.withValues(alpha: 0.3),
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      },
    );
  }
}
