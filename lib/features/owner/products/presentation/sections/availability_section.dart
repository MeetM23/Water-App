import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_toggle_row.dart';
import '../../../../../domain/models/product_draft.dart';
import '../../application/product_form_controller.dart';

/// Stock and visibility toggles.
class AvailabilitySection extends ConsumerWidget {
  /// Creates the availability section.
  const AvailabilitySection({
    required this.productId,
    required this.draft,
    required this.stockQuantityController,
    super.key,
  });

  /// Which form instance this belongs to.
  final String? productId;

  /// The draft being edited.
  final ProductDraft draft;

  /// Controller for stock quantity text field.
  final TextEditingController stockQuantityController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(
      productFormControllerProvider(productId).notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          controller: stockQuantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Available Stock Quantity (pieces) *',
            hintText: 'Enter available stock pieces (e.g. 3, 10, 50)',
            prefixIcon: Icon(Icons.inventory_2_outlined),
          ),
          onChanged: (String val) => controller.setStockQuantity(val),
          validator: (String? val) {
            if (val == null || val.trim().isEmpty) {
              return 'Stock quantity is required';
            }
            if (int.tryParse(val.trim()) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: Spacing.x4),
        AppToggleRow(
          label: l10n.fieldInStockLabel,
          helperText: l10n.fieldInStockHelp,
          value: draft.inStock,
          onChanged: (bool value) => controller.setInStock(value: value),
        ),
        const SizedBox(height: Spacing.x3),
        AppToggleRow(
          label: l10n.fieldActiveLabel,
          helperText: l10n.fieldActiveHelp,
          value: draft.isActive,
          onChanged: (bool value) => controller.setActive(value: value),
        ),
      ],
    );
  }
}
