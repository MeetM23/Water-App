import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_presentation.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../domain/models/product.dart';
import '../../../../domain/models/product_image.dart';
import '../application/product_actions_controller.dart';
import '../application/product_detail_controller.dart';
import 'widgets/barcode_block.dart';

/// Everything known about one product.
class ProductDetailScreen extends ConsumerWidget {
  /// Creates the detail screen.
  const ProductDetailScreen({required this.productId, super.key});

  /// Which product to show.
  final String productId;

  Future<void> _deleteProduct(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.deleteProductTitle,
      message: l10n.deleteProductBody(product.name),
      confirmLabel: l10n.actionDelete,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final controller = ref.read(productActionsControllerProvider.notifier);
    final failure = await controller.delete(product);
    if (!context.mounted) return;

    if (failure != null) {
      AppSnackbar.error(context, failure.title(context.l10n));
    } else {
      AppSnackbar.success(context, context.l10n.productDeleted(product.name));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(productDetailControllerProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        actions: <Widget>[
          IconButton(
            onPressed: () =>
                context.push(AppRoutes.ownerProductEdit(productId)),
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.actionEdit,
          ),
          detail.when(
            data: (value) => IconButton(
              onPressed: () => _deleteProduct(context, ref, value.product),
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              tooltip: l10n.actionDelete,
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: Spacing.x2),
        ],
      ),
      body: detail.when(
        loading: () => const _DetailSkeleton(),
        error: (Object error, StackTrace stackTrace) => AppErrorState(
          failure: error is AppFailure
              ? error
              : UnexpectedFailure(cause: error, stackTrace: stackTrace),
          onRetry: () => ref
              .read(productDetailControllerProvider(productId).notifier)
              .refresh(),
        ),
        data: (ProductDetail value) => RefreshIndicator(
          onRefresh: () => ref
              .read(productDetailControllerProvider(productId).notifier)
              .refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(Spacing.x4),
            children: <Widget>[
              _Gallery(images: value.images),
              const SizedBox(height: Spacing.x5),
              _Header(product: value.product, scanCount: value.scanCount),
              const SizedBox(height: Spacing.x5),
              BarcodeBlock(productCode: value.product.productCode),
              const SizedBox(height: Spacing.x5),
              _PricingCard(product: value.product),
              const SizedBox(height: Spacing.x5),
              _SpecificationsCard(product: value.product),
              if (value.product.description?.isNotEmpty ?? false) ...<Widget>[
                const SizedBox(height: Spacing.x5),
                _DescriptionCard(description: value.product.description!),
              ],
              const SizedBox(height: Spacing.x10),
            ],
          ),
        ),
      ),
    );
  }
}

class _Gallery extends ConsumerWidget {
  const _Gallery({required this.images});

  final List<ProductImage> images;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (images.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.image_outlined,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(height: Spacing.x2),
            Text(
              context.l10n.detailNoImages,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.x3),
        itemBuilder: (BuildContext context, int index) {
          final url = ref.watch(
            signedImageUrlProvider(images[index].storagePath),
          );
          return ClipRRect(
            borderRadius: AppRadius.cardAll,
            child: SizedBox(
              width: 220,
              child: url.when(
                data: (String? value) => value == null
                    ? const ColoredBox(color: AppColors.skeletonBase)
                    : CachedNetworkImage(imageUrl: value, fit: BoxFit.cover),
                loading: () => const ColoredBox(color: AppColors.skeletonBase),
                error: (_, __) =>
                    const ColoredBox(color: AppColors.skeletonBase),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.product, required this.scanCount});

  final Product product;
  final int scanCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          product.name,
          style: context.textTheme.headlineSmall?.copyWith(
            color: AppColors.ink,
          ),
        ),
        if (product.modelNumber != null) ...<Widget>[
          const SizedBox(height: Spacing.x1),
          Text(
            product.modelNumber!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: Spacing.x3),
        Wrap(
          spacing: Spacing.x2,
          runSpacing: Spacing.x2,
          children: <Widget>[
            AppBadge(
              label: (product.inStock && product.availableStock > 0)
                  ? 'Stock: ${product.availableStock} pcs'
                  : l10n.badgeOutOfStock,
              tone: (product.inStock && product.availableStock > 0)
                  ? AppBadgeTone.success
                  : AppBadgeTone.warning,
            ),
            if (!product.isActive)
              AppBadge(label: l10n.badgeInactive, tone: AppBadgeTone.neutral),
            if (product.warrantyMonths != null)
              AppBadge(
                label: l10n.detailWarranty(product.warrantyMonths!),
                tone: AppBadgeTone.neutral,
              ),
          ],
        ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final marginPercent = product.dealerMarginPercent;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.detailPricing,
            style: context.textTheme.titleSmall?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: Spacing.x4),
          _Row(label: l10n.labelWholesale, value: product.wholesalePrice),
          _Row(label: l10n.labelRetail, value: product.retailPrice),
          if (product.mrp != null)
            _Row(label: l10n.labelMrp, value: product.mrp!),
          const Divider(height: Spacing.x6),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.labelMargin,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                marginPercent == null
                    ? AppFormat.rupees(product.dealerMargin)
                    : l10n.marginChip(
                        AppFormat.rupees(product.dealerMargin),
                        marginPercent.toStringAsFixed(1),
                      ),
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.x2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            AppFormat.rupees(value),
            style: context.textTheme.bodyLarge?.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class _SpecificationsCard extends StatelessWidget {
  const _SpecificationsCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = product.specifications.entries.toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.detailSpecifications,
            style: context.textTheme.titleSmall?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: Spacing.x4),
          if (product.capacity != null)
            _TextRow(label: l10n.fieldCapacity, value: product.capacity!),
          if (entries.isEmpty && product.capacity == null)
            Text(
              l10n.detailNoSpecifications,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          for (final entry in entries)
            _TextRow(label: entry.key, value: '${entry.value}'),
        ],
      ),
    );
  }
}

class _TextRow extends StatelessWidget {
  const _TextRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.detailDescription,
            style: context.textTheme.titleSmall?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: Spacing.x3),
          Text(
            description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: Padding(
        padding: EdgeInsets.all(Spacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSkeleton(height: 180),
            SizedBox(height: Spacing.x5),
            AppSkeleton(width: 220, height: 22),
            SizedBox(height: Spacing.x3),
            AppSkeleton(width: 140, height: 12),
            SizedBox(height: Spacing.x6),
            AppSkeleton(height: 160),
          ],
        ),
      ),
    );
  }
}
