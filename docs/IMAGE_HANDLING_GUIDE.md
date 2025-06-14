# Advanced Image Handling Guide

The Flutter Riverpod Clean Architecture template includes a robust image handling system for optimized loading, caching, processing, and display of images. This guide explains how to use the various image components and utilities.

## Core Components

### AdvancedImage Widget

The `AdvancedImage` widget provides a sophisticated image loading experience with features like:

- Automatic caching of images
- Placeholder support during loading
- Blur-up image preview thumbnails
- Fade-in animations
- Error handling with customizable error widgets
- Configurable image quality and resizing

```dart
AdvancedImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  placeholder: ShimmerPlaceholder(),
  errorWidget: Icon(Icons.broken_image),
  useThumbnailPreview: true,
  fadeInDuration: Duration(milliseconds: 300),
);
```

### Image Processor

The `ImageProcessor` interface provides methods for image manipulation:

- Resizing images
- Compressing images
- Cropping images
- Applying blur effects
- Converting to grayscale
- Getting image dimensions
- Converting image formats
- Generating thumbnails

```dart
final processor = ref.watch(imageProcessorProvider);

// Resize an image
final resizedImage = await processor.resize(
  imageData: imageBytes,
  width: 800,
  height: 600,
  maintainAspectRatio: true,
);

// Generate a thumbnail
final thumbnail = await processor.generateThumbnail(
  imageData: imageBytes,
  maxDimension: 200,
  quality: 80,
);
```

### SVG Renderer

The `SvgRenderer` handles SVG rendering with caching support:

```dart
// Display an SVG image from assets
SvgImage.asset(
  'assets/images/icon.svg',
  width: 48,
  height: 48,
  color: Colors.blue,
);

// Display an SVG image from network
SvgImage.network(
  'https://example.com/icon.svg',
  width: 48,
  height: 48,
  color: Theme.of(context).primaryColor,
);
```

### Image Transformer

The `ImageTransformer` applies visual effects to images:

```dart
// Define an effect configuration
final grayscaleEffect = ImageEffectConfig(
  effectType: ImageEffectType.grayscale,
  intensity: 0.8,
);

// Apply the effect to an image
ImageTransformer(
  effect: grayscaleEffect,
  child: Image.asset('assets/images/photo.jpg'),
);

// Or use with a provider for dynamic effects
final effectProvider = Provider<ImageEffectConfig>((ref) {
  return ImageEffectConfig(
    effectType: ImageEffectType.sepia,
    intensity: 0.7,
  );
});

TransformedImage(
  child: Image.network('https://example.com/photo.jpg'),
  effectProvider: effectProvider,
);
```

### Shimmer Placeholders

Beautiful loading placeholders with shimmer effects:

```dart
// Simple shimmer placeholder
ShimmerPlaceholder(
  width: 200,
  height: 200,
  borderRadius: BorderRadius.circular(8),
);

// Image card skeleton with title and description
ImageCardSkeleton(
  width: 200,
  height: 300,
  showTitle: true,
  showDescription: true,
);

// Grid of placeholders for a gallery
ImagePlaceholderGrid(
  itemCount: 6,
  crossAxisCount: 2,
);
```

## Caching System

Images are cached at two levels:

1. **Memory Cache**: For ultra-fast access to recently used images
2. **Disk Cache**: For persistent storage of images across app launches

The cache configuration can be customized:

```dart
// Configure the image memory cache
final customImageCacheProvider = Provider<CacheManager<ui.Image>>((ref) {
  return CacheManager<ui.Image>(maxItems: 200);
});

// Use the custom cache
ref.read(advancedImageConfigProvider.notifier).update((state) => 
  state.copyWith(memoryCacheProvider: customImageCacheProvider)
);
```

## Best Practices

### Image Optimization

1. **Use appropriate image dimensions**: Avoid loading images larger than needed
2. **Enable auto-resizing**: Set `enableAutoResize` to true in `AdvancedImageConfig`
3. **Use thumbnails**: Generate and display thumbnails for lists and grids

### Performance

1. **Enable caching**: Ensure `enableCaching` is true in `AdvancedImageConfig`
2. **Use blur-up previews**: Enable `useThumbnailPreview` for better perceived performance
3. **Lazy load images**: Only load images when they become visible

### Accessibility

1. **Provide semantic labels**: Add descriptive text for screen readers
2. **Handle errors gracefully**: Always provide meaningful error widgets
3. **Show loading indicators**: Use shimmer placeholders during loading

## Examples

### Basic Image Gallery

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
  ),
  itemCount: images.length,
  itemBuilder: (context, index) {
    return AdvancedImage(
      imageUrl: images[index].url,
      placeholder: ShimmerPlaceholder(),
      errorWidget: Icon(Icons.broken_image),
    );
  },
);
```

### Profile Picture with Effects

```dart
TransformedImage(
  effectProvider: userProfileEffectProvider,
  child: AdvancedImage(
    imageUrl: user.avatarUrl,
    width: 120,
    height: 120,
    fit: BoxFit.cover,
    placeholder: ShimmerPlaceholder(shape: BoxShape.circle),
  ),
);
```

### Product Image with SVG Badge

```dart
Stack(
  children: [
    AdvancedImage(
      imageUrl: product.imageUrl,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
    ),
    if (product.isNew)
      Positioned(
        top: 8,
        right: 8,
        child: SvgImage.asset(
          'assets/images/new_badge.svg',
          width: 40,
          height: 40,
        ),
      ),
  ],
);
```

## Advanced Use Cases

### Custom Image Processor

You can create your own implementation of the `ImageProcessor` interface:

```dart
class FirebaseImageProcessor implements ImageProcessor {
  // Implementation using Firebase ML Kit or other libraries
  // ...
}

final customImageProcessorProvider = Provider<ImageProcessor>((ref) {
  return FirebaseImageProcessor();
});
```

### Custom Effects

Create custom image effects by extending the `ImageEffectType` enum and updating the `ImageTransformer` widget:

```dart
extension CustomImageEffects on ImageEffectType {
  static const duotone = ImageEffectType.duotone;
}

// Then in your ImageTransformer implementation:
case CustomImageEffects.duotone:
  return ColorFiltered(
    colorFilter: ColorFilter.matrix(_getDuotoneMatrix(
      effect.intensity,
      effect.overlayColor ?? Colors.blue,
    )),
    child: child,
  );
```

### Prefetching Images

Improve the user experience by prefetching images before they're needed:

```dart
Future<void> prefetchImagesForGallery(List<String> imageUrls) async {
  final processor = ref.read(imageProcessorProvider);
  final cache = ref.read(imageMemoryCacheProvider);
  
  for (final url in imageUrls) {
    // Check if already cached
    final key = ref.read(imageKeyProvider(url));
    if (!cache.containsKey(key)) {
      // Fetch and cache in background
      unawaited(_fetchAndCacheImage(url, processor, cache, key));
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Images not loading**: Check network connectivity and verify URLs
2. **Poor performance**: Reduce image dimensions or enable auto-resizing
3. **High memory usage**: Decrease the memory cache size or enable aggressive caching

### Testing Image Loading

Test image loading in various network conditions:

```dart
// Simulate slow network
Future<void> testSlowImageLoading() async {
  final tester = await WidgetTester.create();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        imageProcessorProvider.overrideWithValue(
          SlowNetworkImageProcessor(),
        ),
      ],
      child: MyApp(),
    ),
  );
  
  // Verify loading behavior
  expect(find.byType(ShimmerPlaceholder), findsWidgets);
  await tester.pump(Duration(seconds: 5));
  expect(find.byType(ShimmerPlaceholder), findsNothing);
}
```
