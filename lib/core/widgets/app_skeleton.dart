import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Drives the shimmer sweep for every [AppSkeleton] beneath it.
///
/// One controller animates a whole placeholder screen, rather than each block
/// owning a controller of its own. Wrap the skeleton layout in this; the blocks
/// themselves stay stateless.
class AppShimmer extends StatefulWidget {
  /// Wraps [child] in a repeating shimmer sweep.
  const AppShimmer({required this.child, super.key});

  /// The skeleton layout to sweep across.
  final Widget child;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            final slide = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(slide - 1, 0),
              end: Alignment(slide + 1, 0),
              colors: const <Color>[
                AppColors.skeletonBase,
                AppColors.skeletonHighlight,
                AppColors.skeletonBase,
              ],
              stops: const <double>[0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A single grey block standing in for content that has not arrived yet.
///
/// Compose these into the shape of the real screen, so the layout does not jump
/// when data lands. A bare spinner in the middle of a screen is not acceptable
/// anywhere in this app.
class AppSkeleton extends StatelessWidget {
  /// Creates a rectangular placeholder block.
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = AppRadius.controlAll,
  });

  /// Creates a circular placeholder, for avatars and icon wells.
  AppSkeleton.circle({required double size, Key? key})
    : this(
        key: key,
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(size / 2),
      );

  /// Block width. Null fills the available width.
  final double? width;

  /// Block height.
  final double height;

  /// Corner rounding.
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.skeletonBase,
        borderRadius: borderRadius,
      ),
    );
  }
}
