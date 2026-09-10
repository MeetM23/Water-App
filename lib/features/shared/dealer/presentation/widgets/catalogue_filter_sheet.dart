import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../domain/enums/product_category.dart';
import '../../application/catalogue_controller.dart';
import '../category_label.dart';

/// Category and ordering for the catalogue grid, in one bottom sheet.
///
/// Every tap applies immediately rather than waiting on a confirm button, so
/// the dealer can watch the grid narrow behind the sheet and back out of a
/// choice that was not what they meant.
class CatalogueFilterSheet extends ConsumerWidget {
  /// Creates the filter sheet.
  const CatalogueFilterSheet({required this.onReset, super.key});

  /// Clears the query *and* the search box, which lives on the screen.
  ///
  /// Resetting the query alone would leave text sitting in a field that no
  /// longer filters anything, so the screen owns the whole reset and the sheet
  /// only asks for it.
  final VoidCallback onReset;

  /// Opens the sheet.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onReset,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => CatalogueFilterSheet(onReset: onReset),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(catalogueQueryControllerProvider);
    final controller = ref.read(catalogueQueryControllerProvider.notifier);

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
                      label: category.catalogueLabel(l10n),
                      isSelected: query.category == category,
                      onSelected: () => controller.setCategory(category),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.x5),
              _GroupLabel(label: l10n.catalogueSortLabel),
              Wrap(
                spacing: Spacing.x2,
                runSpacing: Spacing.x2,
                children: <Widget>[
                  for (final sort in CatalogueSort.values)
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
                      onPressed: onReset,
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

/// Localised name for an ordering.
String _sortLabel(BuildContext context, CatalogueSort sort) {
  final l10n = context.l10n;
  return switch (sort) {
    CatalogueSort.name => l10n.catalogueSortName,
    CatalogueSort.priceAscending => l10n.catalogueSortPriceLow,
    CatalogueSort.priceDescending => l10n.catalogueSortPriceHigh,
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
