import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/cache_manager.dart';

/// Provider for SVG cache
final svgCacheProvider = Provider<CacheManager<ui.Image>>((ref) {
  return CacheManager<ui.Image>(maxItems: 50);
});

/// A service that handles SVG rendering
class SvgRenderer {
  final CacheManager<ui.Image> _cache;

  /// Creates a new SVG renderer with the given cache
  SvgRenderer(this._cache);

  /// Renders an SVG file from assets to a Flutter Image
  Future<ui.Image> renderSvgAsset(
    String assetName, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    String? semanticsLabel,
  }) async {
    // Create a cache key based on the parameters
    final cacheKey =
        '${assetName}_${width}_${height}_${color?.value}_${colorBlendMode.index}';

    // Check if the SVG is already cached
    final cachedImage = _cache.getItem(cacheKey);
    if (cachedImage != null) {
      return cachedImage;
    }

    // For a real implementation, we would use flutter_svg or similar package
    // This is a debug implementation that loads a PNG placeholder

    debugPrint('🖼️ Rendering SVG asset: $assetName');

    // Simulate SVG rendering time
    await Future.delayed(const Duration(milliseconds: 300));

    // Create a simple colored square as a placeholder for the SVG
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint =
        Paint()
          ..color = color ?? Colors.blue
          ..style = PaintingStyle.fill;

    // Determine dimensions
    final size = Size(width ?? 100, height ?? 100);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw text to indicate this is a debug renderer
    if (kDebugMode) {
      const textStyle = TextStyle(color: Colors.white, fontSize: 14);
      final textSpan = TextSpan(text: 'SVG\nPlaceholder', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(
        canvas,
        Offset(
          size.width / 2 - textPainter.width / 2,
          size.height / 2 - textPainter.height / 2,
        ),
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );

    // Cache the rendered SVG
    _cache.setItem(cacheKey, image);

    return image;
  }

  /// Renders an SVG file from network to a Flutter Image
  Future<ui.Image> renderSvgNetwork(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    Map<String, String>? headers,
    String? semanticsLabel,
  }) async {
    // Create a cache key based on the parameters
    final cacheKey =
        '${url}_${width}_${height}_${color?.value}_${colorBlendMode.index}';

    // Check if the SVG is already cached
    final cachedImage = _cache.getItem(cacheKey);
    if (cachedImage != null) {
      return cachedImage;
    }

    // For a real implementation, we would use flutter_svg or similar package
    // This is a debug implementation that creates a placeholder

    debugPrint('🖼️ Rendering SVG from network: $url');

    // Simulate network loading and SVG rendering time
    await Future.delayed(const Duration(milliseconds: 600));

    // Create a simple colored square as a placeholder for the SVG
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint =
        Paint()
          ..color = color ?? Colors.green
          ..style = PaintingStyle.fill;

    // Determine dimensions
    final size = Size(width ?? 100, height ?? 100);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw text to indicate this is a network SVG placeholder
    if (kDebugMode) {
      const textStyle = TextStyle(color: Colors.white, fontSize: 14);
      final textSpan = TextSpan(
        text: 'Network SVG\nPlaceholder',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(
        canvas,
        Offset(
          size.width / 2 - textPainter.width / 2,
          size.height / 2 - textPainter.height / 2,
        ),
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );

    // Cache the rendered SVG
    _cache.setItem(cacheKey, image);

    return image;
  }
}

/// Provider for the SVG renderer
final svgRendererProvider = Provider<SvgRenderer>((ref) {
  final cache = ref.watch(svgCacheProvider);
  return SvgRenderer(cache);
});

/// A widget that renders SVG files
class SvgImage extends ConsumerWidget {
  final String source;
  final bool isAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final BlendMode colorBlendMode;
  final String? semanticsLabel;
  final Map<String, String>? headers;
  final Widget? placeholder;
  final Widget? errorWidget;

  /// Creates a widget that displays an SVG image
  const SvgImage({
    super.key,
    required this.source,
    this.isAsset = false,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.headers,
    this.placeholder,
    this.errorWidget,
  });

  /// Creates a widget that displays an SVG image from a network URL
  const SvgImage.network(
    String url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.headers,
    this.placeholder,
    this.errorWidget,
  }) : source = url,
       isAsset = false;

  /// Creates a widget that displays an SVG image from an asset bundle
  const SvgImage.asset(
    String assetName, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.placeholder,
    this.errorWidget,
  }) : source = assetName,
       isAsset = true,
       headers = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderer = ref.watch(svgRendererProvider);

    return FutureBuilder<ui.Image>(
      future:
          isAsset
              ? renderer.renderSvgAsset(
                source,
                width: width,
                height: height,
                fit: fit,
                color: color,
                colorBlendMode: colorBlendMode,
                semanticsLabel: semanticsLabel,
              )
              : renderer.renderSvgNetwork(
                source,
                width: width,
                height: height,
                fit: fit,
                color: color,
                colorBlendMode: colorBlendMode,
                headers: headers,
                semanticsLabel: semanticsLabel,
              ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ??
              SizedBox(
                width: width,
                height: height,
                child: const Center(child: CircularProgressIndicator()),
              );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return errorWidget ??
              SizedBox(
                width: width,
                height: height,
                child: const Icon(Icons.error_outline, color: Colors.red),
              );
        }

        return RawImage(
          image: snapshot.data,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
}
