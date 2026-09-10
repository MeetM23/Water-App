import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_skeleton.dart';
import '../../../../../domain/models/catalog_product.dart';
import '../../application/product_images_controller.dart';
import 'catalogue_image.dart';
import 'fullscreen_gallery.dart';

/// The photo strip at the top of the dealer product screen.
///
/// One photo at a time rather than a scrolling row of thumbnails: a dealer
/// holds this up to show somebody, and a 4:3 tile the width of the phone is
/// the largest a product reads at without leaving the screen.
class ProductGallery extends ConsumerStatefulWidget {
  /// Creates the gallery for [product].
  const ProductGallery({required this.product, super.key});

  /// The product whose photos are shown.
  final CatalogProduct product;

  @override
  ConsumerState<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends ConsumerState<ProductGallery> {
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _open(List<String> storagePaths, int index) =>
      FullscreenGallery.show(
        context,
        storagePaths: storagePaths,
        initialIndex: index,
        onIndexChanged: _followViewer,
      );

  /// Keeps the strip on whichever photo the viewer is showing.
  ///
  /// Two things depend on this: the dealer comes back to the photo they were
  /// looking at rather than the one they opened, and the hero has a tile of
  /// the same tag to fly home to.
  void _followViewer(int index) {
    if (!mounted || !_pageController.hasClients) {
      return;
    }
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(
      productImagesProvider(widget.product.id, widget.product.primaryImagePath),
    );

    return images.when(
      loading: () => const AppShimmer(
        child: _GalleryFrame(child: ColoredBox(color: AppColors.skeletonBase)),
      ),
      // The provider swallows its own failures and falls back to the cached
      // primary image, so this arm is defensive rather than expected.
      error: (Object error, StackTrace stackTrace) => const _GalleryEmpty(),
      data: (List<String> storagePaths) => storagePaths.isEmpty
          ? const _GalleryEmpty()
          : _buildPager(storagePaths),
    );
  }

  Widget _buildPager(List<String> storagePaths) {
    return Column(
      children: <Widget>[
        _GalleryFrame(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int index) => setState(() => _index = index),
            itemCount: storagePaths.length,
            itemBuilder: (BuildContext context, int index) => GestureDetector(
              onTap: () => _open(storagePaths, index),
              child: Hero(
                tag: galleryHeroTag(storagePaths[index], index),
                child: CatalogueImage(storagePath: storagePaths[index]),
              ),
            ),
          ),
        ),
        if (storagePaths.length > 1) ...<Widget>[
          const SizedBox(height: Spacing.x3),
          GalleryPageDots(count: storagePaths.length, index: _index),
        ],
      ],
    );
  }
}

class _GalleryFrame extends StatelessWidget {
  const _GalleryFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.cardAll,
        // A ratio rather than a fixed height, so the strip is the same shape
        // on a 320dp phone as on a tablet instead of being cropped on one of
        // them.
        child: AspectRatio(aspectRatio: 4 / 3, child: child),
      ),
    );
  }
}

class _GalleryEmpty extends StatelessWidget {
  const _GalleryEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      // A minimum, not a fixed height: at a large system text scale the line
      // under the icon needs more room than a 4:3 box would give it, and it
      // has to be free to grow rather than overflow.
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.all(Spacing.x5),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.image_outlined, size: 32, color: AppColors.primary),
          const SizedBox(height: Spacing.x2),
          Text(
            context.l10n.productNoImages,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
