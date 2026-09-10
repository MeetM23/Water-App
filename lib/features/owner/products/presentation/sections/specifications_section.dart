import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_stepper_field.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../domain/models/product_draft.dart';
import '../../application/product_form_controller.dart';

/// Capacity, warranty, and free-form key/value rows.
///
/// The key/value rows go into the specifications jsonb column: a fixed set of
/// fields cannot describe both a domestic purifier and a 3000 LPH industrial
/// plant, so the owner names those attributes themselves. Capacity and
/// warranty sit alongside them because they are what a dealer asks about
/// first, and they have their own columns rather than living in the jsonb.
class SpecificationsSection extends ConsumerWidget {
  /// Creates the specifications section.
  const SpecificationsSection({
    required this.productId,
    required this.draft,
    required this.capacityController,
    super.key,
  });

  /// Which form instance this belongs to.
  final String? productId;

  /// The draft being edited.
  final ProductDraft draft;

  /// Controller for the capacity string.
  final TextEditingController capacityController;

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
          label: l10n.fieldCapacity,
          controller: capacityController,
          helperText: l10n.capacityHelp,
          trailingLabel: l10n.fieldOptional,
          textInputAction: TextInputAction.next,
          onChanged: controller.setCapacity,
        ),
        const SizedBox(height: Spacing.x5),
        AppStepperField(
          label: l10n.fieldWarrantyMonths,
          value: draft.warrantyMonths,
          maximum: 120,
          onChanged: controller.setWarrantyMonths,
        ),
        const SizedBox(height: Spacing.x6),
        Text(
          l10n.specDetailsLabel,
          style: context.textTheme.labelLarge?.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: Spacing.x2),
        if (draft.specifications.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.x4),
            child: Text(
              l10n.specEmpty,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        for (final entry in draft.specifications)
          Padding(
            key: ValueKey<String>(entry.id),
            padding: const EdgeInsets.only(bottom: Spacing.x3),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    initialValue: entry.key,
                    decoration: InputDecoration(hintText: l10n.specKeyHint),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (String value) =>
                        controller.updateSpecification(entry.id, key: value),
                  ),
                ),
                const SizedBox(width: Spacing.x2),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    initialValue: entry.value,
                    decoration: InputDecoration(hintText: l10n.specValueHint),
                    onChanged: (String value) =>
                        controller.updateSpecification(entry.id, value: value),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.removeSpecification(entry.id),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.textSecondary,
                  tooltip: l10n.actionRemove,
                ),
              ],
            ),
          ),
        AppButton(
          label: l10n.specAddRow,
          onPressed: controller.addSpecification,
          icon: Icons.add_rounded,
          variant: AppButtonVariant.text,
          isExpanded: false,
        ),
      ],
    );
  }
}
