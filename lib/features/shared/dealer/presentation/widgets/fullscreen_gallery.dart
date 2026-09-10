import 'package:flutter/material.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'catalogue_image.dart';

/// The hero tag shared by a gallery tile and its full-screen counterpart.
///
/// The index is part of the tag because a tag has to be unique inside a route,
/// and nothing in the database stops one product from listing the same storage
/// path twice.
String galleryHeroTag(String storagePath, int index) =>
    'gallery-$index-$storagePath';

/// The page-position dots under a gallery.
///
/// Shared by the strip on the product screen and by the full-screen viewer it
/// opens, so a dealer's place in the photos reads the same in both. The
/// colours are parameters because one sits on white and the other on ink.
class GalleryPageDots extends StatelessWidget {
  /// Creates the indicator.
  const GalleryPageDots({
    required this.count,
    required this.index,
    super.key,
    this.activeColor = AppColors.primary,
    this.inactiveColor = AppColors.border,
  });

  /// How many pages there are.
  final int count;

  /// Which page is showing.
  final int index;

  /// Colour of the current page's dot.
  final Color activeColor;

  /// Colour of every other dot.
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int dot = 0; dot < count; dot++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: Spacing.x1),
            height: Spacing.x2,
            width: dot == index ? Spacing.x5 : Spacing.x2,
            decoration: BoxDecoration(
              color: dot == index ? activeColor : inactiveColor,
              borderRadius: AppRadius.pillAll,
            ),
          ),
      ],
    );
  }
}

/// One product photo at full size, zoomable and swipeable.
///
/// A dealer showing a purifier to a customer is holding a five-inch screen at
/// arm's length, and the thing they get asked about is the port on the back.
/// So this takes the chrome away and gives them the whole screen, an ink
/// ground that does not compete with the photograph, and pinch to zoom.
class FullscreenGallery extends StatefulWidget {
  /// Creates the viewer.
  const FullscreenGallery({
    required this.storagePaths,
    required this.initialIndex,
    required this.onIndexChanged,
    super.key,
  });

  /// Opens the viewer over the current route.
  ///
  /// [onIndexChanged] reports each swipe as it happens rather than handing an
  /// index back on the way out, so the strip underneath ends up on the photo
  /// the dealer was looking at however the viewer was dismissed - close
  /// button, back gesture or system back.
  static Future<void> show(
    BuildContext context, {
    required List<String> storagePaths,
    required int initialIndex,
    required ValueChanged<int> onIndexChanged,
  }) => Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      pageBuilder: (_, __, ___) => FullscreenGallery(
        storagePaths: storagePaths,
        initialIndex: initialIndex,
        onIndexChanged: onIndexChanged,
      ),
      // A fade, because the hero carries the motion. A slide underneath it
      // would drag the photograph sideways while it is still growing.
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 220),
    ),
  );

  /// The photos to page through.
  final List<String> storagePaths;

  /// Which photo the dealer tapped.
  final int initialIndex;

  /// Called with the page currently on screen.
  final ValueChanged<int> onIndexChanged;

  @override
  State<FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  bool _isZoomed = false;
  bool _hasZoomed = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _index = index;
      // A photo that scrolls in is never zoomed, and a stale flag would leave
      // the pager locked on it.
      _isZoomed = false;
    });
    widget.onIndexChanged(index);
  }

  void _onZoomChanged(bool isZoomed) {
    if (isZoomed == _isZoomed) {
      return;
    }
    setState(() {
      _isZoomed = isZoomed;
      _hasZoomed = _hasZoomed || isZoomed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _pageController,
            // A zoomed photo owns the drag. Without this the first pan
            // sideways flips to the next photo instead of moving the image,
            // which is exactly when the dealer is trying to look at a detail.
            physics: _isZoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            onPageChanged: _onPageChanged,
            itemCount: widget.storagePaths.length,
            itemBuilder: (BuildContext context, int index) => _ZoomablePage(
              storagePath: widget.storagePaths[index],
              heroTag: galleryHeroTag(widget.storagePaths[index], index),
              onZoomChanged: _onZoomChanged,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.x2),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _CloseButton(tooltip: l10n.actionDone),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.x6,
                  0,
                  Spacing.x6,
                  Spacing.x6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (widget.storagePaths.length > 1) ...<Widget>[
                      GalleryPageDots(
                        count: widget.storagePaths.length,
                        index: _index,
                        activeColor: AppColors.surface,
                        inactiveColor: AppColors.textSecondary,
                      ),
                      const SizedBox(height: Spacing.x4),
                    ],
                    // The hint retires once it has been obeyed: a permanent
                    // caption over a photograph is just something in the way.
                    AnimatedOpacity(
                      opacity: _hasZoomed ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: _ZoomHint(label: l10n.productZoomHint),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One page of the viewer, owning its own zoom.
///
/// Per page rather than one controller for the whole viewer, because a shared
/// transform would carry the zoom onto the next photo as it scrolls in.
class _ZoomablePage extends StatefulWidget {
  const _ZoomablePage({
    required this.storagePath,
    required this.heroTag,
    required this.onZoomChanged,
  });

  final String storagePath;
  final String heroTag;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage> {
  final TransformationController _controller = TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransform);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTransform)
      ..dispose();
    super.dispose();
  }

  void _onTransform() {
    // A margin above 1, not equality: a pinch that settles a hair off the
    // minimum should not leave the pager disabled with nothing on screen to
    // explain why.
    final isZoomed = _controller.value.getMaxScaleOnAxis() > 1.01;
    if (isZoomed == _isZoomed) {
      return;
    }
    _isZoomed = isZoomed;
    widget.onZoomChanged(isZoomed);
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: 1,
      maxScale: 4,
      // Expanded rather than centred: the decoded photo is wider than a 320dp
      // screen, so it needs tight constraints to letterbox against instead of
      // its own intrinsic size to overflow with.
      child: SizedBox.expand(
        child: Hero(
          tag: widget.heroTag,
          child: CatalogueImage(
            storagePath: widget.storagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.tooltip});

  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.scrim,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close_rounded),
        color: AppColors.surface,
        tooltip: tooltip,
      ),
    );
  }
}

class _ZoomHint extends StatelessWidget {
  const _ZoomHint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.scrim,
        borderRadius: AppRadius.pillAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.x4,
          vertical: Spacing.x2,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.surface,
          ),
        ),
      ),
    );
  }
}
