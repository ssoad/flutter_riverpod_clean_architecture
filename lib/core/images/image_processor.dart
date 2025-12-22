import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Interface for image processing and manipulation
abstract class ImageProcessor {
  /// Resize an image to the given dimensions
  Future<Uint8List> resize({
    required Uint8List imageData,
    required int width,
    required int height,
    bool maintainAspectRatio = true,
  });

  /// Compress an image to reduce its file size
  Future<Uint8List> compress({
    required Uint8List imageData,
    required int quality,
  });

  /// Crop an image to the given rectangle
  Future<Uint8List> crop({
    required Uint8List imageData,
    required Rect cropRect,
  });

  /// Apply a blur effect to the image
  Future<Uint8List> applyBlur({
    required Uint8List imageData,
    required double sigma,
  });

  /// Convert image to grayscale
  Future<Uint8List> toGrayscale({required Uint8List imageData});

  /// Get the dimensions of an image
  Future<Size> getImageDimensions(Uint8List imageData);

  /// Convert an image to a specific format
  Future<Uint8List> convertFormat({
    required Uint8List imageData,
    required ImageFormat format,
    int quality = 95,
  });

  /// Generate a thumbnail for the image
  Future<Uint8List> generateThumbnail({
    required Uint8List imageData,
    required int maxDimension,
    int quality = 80,
  });
}

/// Image file formats
enum ImageFormat { jpeg, png, webp }

/// Helper class for working with image dimensions
class Size {
  final int width;
  final int height;

  const Size(this.width, this.height);

  @override
  String toString() => 'Size($width x $height)';
}

/// Helper class for defining crop rectangles
class Rect {
  final int x;
  final int y;
  final int width;
  final int height;

  const Rect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  @override
  String toString() => 'Rect(x: $x, y: $y, width: $width, height: $height)';
}
