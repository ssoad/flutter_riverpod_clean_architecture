import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/debug_image_processor.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/image_processor.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/cache_manager.dart';

/// Provider for the image processor
final imageProcessorProvider = Provider<ImageProcessor>((ref) {
  return DebugImageProcessor();
});

/// Configuration for advanced image handling
class AdvancedImageConfig {
  /// Whether to cache images locally
  final bool enableCaching;

  /// Whether to enable automatic image resizing
  final bool enableAutoResize;

  /// Maximum width for auto-resized images
  final int? maxWidth;

  /// Maximum height for auto-resized images
  final int? maxHeight;

  /// Default quality for JPEG or WebP compression (0-100)
  final int defaultQuality;

  /// Whether to enable blur-up preview thumbnails
  final bool enableBlurUpPreview;

  /// Size of blur-up preview thumbnails
  final int blurUpPreviewSize;

  /// Default image format
  final ImageFormat defaultFormat;

  const AdvancedImageConfig({
    this.enableCaching = true,
    this.enableAutoResize = true,
    this.maxWidth,
    this.maxHeight,
    this.defaultQuality = 85,
    this.enableBlurUpPreview = true,
    this.blurUpPreviewSize = 20,
    this.defaultFormat = ImageFormat.jpeg,
  });
}

/// Provider for advanced image configuration
final advancedImageConfigProvider = Provider<AdvancedImageConfig>((ref) {
  return const AdvancedImageConfig();
});

/// In-memory cache for decoded images
final imageMemoryCacheProvider = Provider<CacheManager<ui.Image>>((ref) {
  return CacheManager<ui.Image>(maxItems: 100);
});

/// Provider for image cache keys
final imageKeyProvider = Provider.family<String, String>((ref, imageUrl) {
  final config = ref.watch(advancedImageConfigProvider);

  // Create a cache key that includes relevant sizing parameters
  String key = imageUrl;
  if (config.enableAutoResize &&
      (config.maxWidth != null || config.maxHeight != null)) {
    key += "_w${config.maxWidth ?? 'auto'}_h${config.maxHeight ?? 'auto'}";
  }

  return key;
});

/// Advanced image widget with caching, processing, and placeholder support
class AdvancedImage extends ConsumerStatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool useThumbnailPreview;
  final Duration fadeInDuration;
  final Color? placeholderColor;

  const AdvancedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.useThumbnailPreview = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderColor,
  });

  @override
  ConsumerState<AdvancedImage> createState() => _AdvancedImageState();
}

class _AdvancedImageState extends ConsumerState<AdvancedImage> {
  bool _loading = true;
  bool _error = false;
  ImageProvider? _imageProvider;
  ImageProvider? _thumbnailProvider;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(AdvancedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      // In a real implementation, this would handle network images, resizing, etc.
      // For now, we'll just use a simple NetworkImage
      final imageProvider = NetworkImage(widget.imageUrl);

      // Simulate loading a thumbnail
      if (widget.useThumbnailPreview) {
        _thumbnailProvider = NetworkImage(
          widget.imageUrl,
        ); // In real app, would be a tiny version
        setState(() {}); // Refresh to show thumbnail
      }

      // Simulate image loading delay
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _imageProvider = imageProvider;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Failed to load image: $e');
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error && widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    if (_loading && _thumbnailProvider == null) {
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: widget.placeholderColor ?? Colors.grey.shade200,
          );
    }

    if (_loading && _thumbnailProvider != null) {
      return Stack(
        children: [
          Image(
            image: _thumbnailProvider!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      );
    }

    return FadeInImage(
      placeholder: _thumbnailProvider ?? MemoryImage(Uint8List.fromList([])),
      image: _imageProvider!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      fadeInDuration: widget.fadeInDuration,
      imageErrorBuilder: (_, __, ___) {
        return widget.errorWidget ??
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.red.withValues(alpha: 0.1),
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.red),
              ),
            );
      },
    );
  }
}
