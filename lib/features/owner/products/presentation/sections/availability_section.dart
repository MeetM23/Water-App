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
    super.key,
  });

  /// Which form instance this belongs to.
  final String? productId;

  /// The draft being edited.
  final ProductDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(
      productFormControllerProvider(productId).notifier,
    );

    return Column(
      children: <Widget>[
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
