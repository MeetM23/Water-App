import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../domain/enums/product_category.dart';
import '../../../../../domain/models/product_draft.dart';
import '../../application/product_form_controller.dart';

/// Name, model number, category and description.
class BasicDetailsSection extends ConsumerWidget {
  /// Creates the basic details section.
  const BasicDetailsSection({
    required this.productId,
    required this.draft,
    required this.nameController,
    required this.modelController,
    required this.descriptionController,
    required this.hasAttemptedSubmit,
    super.key,
  });

  /// Which form instance this belongs to.
  final String? productId;

  /// The draft being edited.
  final ProductDraft draft;

  /// Controller for the product name.
  final TextEditingController nameController;

  /// Controller for the model number.
  final TextEditingController modelController;

  /// Controller for the description.
  final TextEditingController descriptionController;

  /// Whether Save has been pressed, which is what reveals the category error.
  final bool hasAttemptedSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(
      productFormControllerProvider(productId).notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppTextField(
          label: l10n.fieldProductName,
          controller: nameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          onChanged: controller.setName,
          validator: (String? value) =>
              Validators.name(value, l10n, l10n.fieldProductName),
        ),
        const SizedBox(height: Spacing.x5),
        AppTextField(
          label: l10n.fieldModelNumber,
          controller: modelController,
          trailingLabel: l10n.fieldOptional,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.characters,
          onChanged: controller.setModelNumber,
        ),
        const SizedBox(height: Spacing.x5),
        Text(
          l10n.fieldCategoryLabel,
          style: context.textTheme.labelLarge?.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: Spacing.x2),
        Wrap(
          spacing: Spacing.x2,
          runSpacing: Spacing.x2,
          children: <Widget>[
            for (final category in ProductCategory.values.where((c) => c != ProductCategory.sparePart))
              ChoiceChip(
                label: Text(_categoryLabel(context, category)),
                selected: draft.category == category,
                showCheckmark: false,
                onSelected: (_) => controller.setCategory(category),
              ),
          ],
        ),
        if (draft.category == null && hasAttemptedSubmit) ...<Widget>[
          const SizedBox(height: Spacing.x2),
          Text(
            l10n.validationRequired(l10n.fieldCategoryLabel),
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.danger,
            ),
          ),
        ],
        const SizedBox(height: Spacing.x5),
        AppTextField(
          label: l10n.fieldDescription,
          controller: descriptionController,
          trailingLabel: l10n.fieldOptional,
          textCapitalization: TextCapitalization.sentences,
          onChanged: controller.setDescription,
        ),
      ],
    );
  }

  static String _categoryLabel(BuildContext context, ProductCategory category) {
    final l10n = context.l10n;
    return switch (category) {
      ProductCategory.domestic => l10n.categoryDomestic,
      ProductCategory.commercial => l10n.categoryCommercial,
      ProductCategory.industrial => l10n.categoryIndustrial,
      ProductCategory.sparePart => l10n.categorySparePart,
      ProductCategory.accessory => l10n.categoryAccessory,
    };
  }
}
