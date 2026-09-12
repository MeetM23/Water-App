import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/app_badge.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../domain/models/product.dart';
import '../../application/product_detail_controller.dart';

/// One product row in the owner catalogue.
///
/// Both prices are shown side by side and explicitly labelled. This is the
/// owner's screen: showing them together is the point, and it is safe precisely
/// because row level security means no dealer can ever load this data.
class ProductCard extends ConsumerWidget {
  /// Creates a product card.
  const ProductCard({
    required this.product,
    required this.onTap,
    required this.onLongPress,
    super.key,
    this.primaryImagePath,
  });

  /// The product to render.
  final Product product;

  /// Opens the detail screen.
  final VoidCallback onTap;

  /// Opens the quick-action sheet.
  final VoidCallback onLongPress;

  /// Storage path of the thumbnail, when one is known.
  final String? primaryImagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Semantics(
      button: true,
      label: product.name,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: AppCard(
          onTap: onTap,
          padding: const EdgeInsets.all(Spacing.x3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Thumbnail(storagePath: primaryImagePath),
              const SizedBox(width: Spacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded, size: 20),
                          onPressed: onLongPress,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Options',
                        ),
                      ],
                    ),
                    if (product.modelNumber != null) ...<Widget>[
                      const SizedBox(height: Spacing.x1),
                      Text(
                        product.modelNumber!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: Spacing.x2),
                    Text(
                      product.productCode,
                      style: AppTypography.mono.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: Spacing.x3),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _PriceColumn(
                            label: l10n.labelWholesale,
                            value: product.wholesalePrice,
                          ),
                        ),
                        Expanded(
                          child: _PriceColumn(
                            label: l10n.labelRetail,
                            value: product.retailPrice,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.x3),
                    Wrap(
                      spacing: Spacing.x2,
                      runSpacing: Spacing.x1,
                      children: <Widget>[
                        AppBadge(
                          label: _categoryLabel(context),
                          tone: AppBadgeTone.info,
                        ),
                        AppBadge(
                          label: (product.inStock && product.availableStock > 0)
                              ? 'Stock: ${product.availableStock} pcs'
                              : l10n.badgeOutOfStock,
                          tone: (product.inStock && product.availableStock > 0)
                              ? AppBadgeTone.success
                              : AppBadgeTone.warning,
                        ),
                        if (!product.isActive)
                          AppBadge(
                            label: l10n.badgeInactive,
                            tone: AppBadgeTone.neutral,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (product.category.name) {
      'domestic' => l10n.categoryDomestic,
      'commercial' => l10n.categoryCommercial,
      'industrial' => l10n.categoryIndustrial,
      'sparePart' => l10n.categorySparePart,
      _ => l10n.categoryAccessory,
    };
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          AppFormat.rupees(value),
          style: context.textTheme.titleSmall?.copyWith(color: AppColors.ink),
        ),
      ],
    );
  }
}

/// Product thumbnail resolved through a signed URL.
class _Thumbnail extends ConsumerWidget {
  const _Thumbnail({required this.storagePath});

  final String? storagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double size = 72;

    if (storagePath == null) {
      return const _ThumbnailPlaceholder(size: size);
    }

    final url = ref.watch(signedImageUrlProvider(storagePath!));

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: SizedBox(
        height: size,
        width: size,
        child: url.when(
          data: (String? value) => value == null
              ? const _ThumbnailPlaceholder(size: size)
              : CachedNetworkImage(
                  imageUrl: value,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      const ColoredBox(color: AppColors.skeletonBase),
                  errorWidget: (_, __, ___) =>
                      const _ThumbnailPlaceholder(size: size),
                ),
          loading: () => const ColoredBox(color: AppColors.skeletonBase),
          error: (_, __) => const _ThumbnailPlaceholder(size: size),
        ),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: const Icon(
        Icons.water_drop_outlined,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}
