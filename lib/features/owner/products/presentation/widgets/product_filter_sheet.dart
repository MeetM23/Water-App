import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../domain/enums/product_category.dart';
import '../../../../../domain/enums/product_sort.dart';
import '../../../../../domain/enums/product_status_filter.dart';
import '../../application/product_list_controller.dart';

/// Category, availability and ordering, in one bottom sheet.
///
/// Changes apply as they are tapped rather than on a confirm button, so the
/// owner can see the list narrow behind the sheet.
class ProductFilterSheet extends ConsumerWidget {
  /// Creates the filter sheet.
  const ProductFilterSheet({super.key});

  /// Opens the sheet.
  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const ProductFilterSheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(productQueryControllerProvider);
    final controller = ref.read(productQueryControllerProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.x5,
          Spacing.x2,
          Spacing.x5,
          Spacing.x5,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.filterTitle,
                style: context.textTheme.titleMedium?.copyWith(
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: Spacing.x5),
              _GroupLabel(label: l10n.filterCategory),
              Wrap(
                spacing: Spacing.x2,
                runSpacing: Spacing.x2,
                children: <Widget>[
                  _Choice(
                    label: l10n.categoryAll,
                    isSelected: query.category == null,
                    onSelected: () => controller.setCategory(null),
                  ),
                  for (final category in ProductCategory.values)
                    _Choice(
                      label: _categoryLabel(context, category),
                      isSelected: query.category == category,
                      onSelected: () => controller.setCategory(category),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.x5),
              _GroupLabel(label: l10n.filterStatus),
              Wrap(
                spacing: Spacing.x2,
                runSpacing: Spacing.x2,
                children: <Widget>[
                  for (final status in ProductStatusFilter.values)
                    _Choice(
                      label: _statusLabel(context, status),
                      isSelected: query.status == status,
                      onSelected: () => controller.setStatus(status),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.x5),
              _GroupLabel(label: l10n.filterSort),
              Wrap(
                spacing: Spacing.x2,
                runSpacing: Spacing.x2,
                children: <Widget>[
                  for (final sort in ProductSort.values)
                    _Choice(
                      label: _sortLabel(context, sort),
                      isSelected: query.sort == sort,
                      onSelected: () => controller.setSort(sort),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.x8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppButton(
                      label: l10n.actionReset,
                      onPressed: controller.reset,
                      variant: AppButtonVariant.secondary,
                    ),
                  ),
                  const SizedBox(width: Spacing.x3),
                  Expanded(
                    child: AppButton(
                      label: l10n.actionApply,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Localised name for a category.
String _categoryLabel(BuildContext context, ProductCategory category) {
  final l10n = context.l10n;
  return switch (category) {
    ProductCategory.domestic => l10n.categoryDomestic,
    ProductCategory.commercial => l10n.categoryCommercial,
    ProductCategory.industrial => l10n.categoryIndustrial,
    ProductCategory.sparePart => l10n.categorySparePart,
    ProductCategory.accessory => l10n.categoryAccessory,
  };
}

String _statusLabel(BuildContext context, ProductStatusFilter status) {
  final l10n = context.l10n;
  return switch (status) {
    ProductStatusFilter.all => l10n.statusAll,
    ProductStatusFilter.active => l10n.statusActive,
    ProductStatusFilter.inactive => l10n.statusInactiveFilter,
    ProductStatusFilter.outOfStock => l10n.statusOutOfStockFilter,
  };
}

String _sortLabel(BuildContext context, ProductSort sort) {
  final l10n = context.l10n;
  return switch (sort) {
    ProductSort.newest => l10n.sortNewest,
    ProductSort.name => l10n.sortName,
    ProductSort.priceAscending => l10n.sortPriceLowHigh,
    ProductSort.priceDescending => l10n.sortPriceHighLow,
  };
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.x3),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    );
  }
}
