import 'package:flutter/material.dart';

/// A widget that displays a shimmer effect for image placeholders
class ShimmerPlaceholder extends StatefulWidget {
  /// The width of the placeholder
  final double? width;

  /// The height of the placeholder
  final double? height;

  /// The shape of the placeholder
  final BoxShape shape;

  /// Border radius if shape is BoxShape.rectangle
  final BorderRadius? borderRadius;

  /// Base color for the shimmer effect
  final Color baseColor;

  /// Highlight color for the shimmer effect
  final Color highlightColor;

  /// Duration of one shimmer animation cycle
  final Duration duration;

  /// Creates a shimmer placeholder for images with animated loading effect
  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.baseColor = const Color(0xFFEEEEEE),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius:
                widget.shape == BoxShape.rectangle
                    ? widget.borderRadius ?? BorderRadius.zero
                    : null,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [0.0, _animation.value, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A skeleton placeholder for image cards
class ImageCardSkeleton extends StatelessWidget {
  /// The width of the card
  final double? width;

  /// The height of the card
  final double? height;

  /// The border radius of the card
  final BorderRadius borderRadius;

  /// Whether to show a title skeleton
  final bool showTitle;

  /// Whether to show a description skeleton
  final bool showDescription;

  /// Whether to show a footer skeleton
  final bool showFooter;

  /// Creates a skeleton placeholder for an image card
  const ImageCardSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.showTitle = true,
    this.showDescription = false,
    this.showFooter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ShimmerPlaceholder(
              width: double.infinity,
              borderRadius: BorderRadius.only(
                topLeft: borderRadius.topLeft,
                topRight: borderRadius.topRight,
              ),
            ),
          ),
          if (showTitle || showDescription || showFooter)
            Expanded(
              flex: showDescription ? 2 : 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showTitle) ...[
                      const SizedBox(height: 4),
                      ShimmerPlaceholder(
                        width: width != null ? width! * 0.7 : 120,
                        height: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    if (showDescription) ...[
                      const SizedBox(height: 8),
                      ShimmerPlaceholder(
                        width: double.infinity,
                        height: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      ShimmerPlaceholder(
                        width: width != null ? width! * 0.9 : 160,
                        height: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    if (showFooter) ...[
                      const Spacer(),
                      ShimmerPlaceholder(
                        width: width != null ? width! * 0.4 : 80,
                        height: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A placeholder widget that alternates between cards and circular avatars
class ImagePlaceholderGrid extends StatelessWidget {
  /// The number of placeholders in the grid
  final int itemCount;

  /// The number of columns in the grid
  final int crossAxisCount;

  /// The aspect ratio of the grid cells
  final double childAspectRatio;

  /// The spacing between items horizontally
  final double mainAxisSpacing;

  /// The spacing between items vertically
  final double crossAxisSpacing;

  /// Creates a grid of shimmer placeholders
  const ImagePlaceholderGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Alternate between different placeholder types
        if (index % 3 == 0) {
          return const ShimmerPlaceholder(shape: BoxShape.circle);
        }
        return ImageCardSkeleton(
          showTitle: true,
          showDescription: index % 2 == 0,
          showFooter: index % 4 == 0,
        );
      },
    );
  }
}
