import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_badge.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../domain/models/product_draft.dart';
import '../../application/product_form_controller.dart';

/// Code & Barcode generation mode selection (Auto vs Manual) with live stock series preview.
class BarcodeModeSection extends ConsumerWidget {
  /// Creates the barcode mode section.
  const BarcodeModeSection({
    required this.productId,
    required this.draft,
    required this.customCodeController,
    super.key,
  });

  /// Which form instance this belongs to.
  final String? productId;

  /// The draft being edited.
  final ProductDraft draft;

  /// Controller for the custom barcode/code input.
  final TextEditingController customCodeController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      productFormControllerProvider(productId).notifier,
    );

    final generatedSerials = draft.generateStockSerials();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'CODE & BARCODE GENERATION',
          style: context.textTheme.labelLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.x2),
        Row(
          children: <Widget>[
            Expanded(
              child: ChoiceChip(
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.auto_awesome, size: 16),
                    SizedBox(width: Spacing.x2),
                    Text('Auto Generate'),
                  ],
                ),
                selected: !draft.isManualCode,
                showCheckmark: false,
                onSelected: (_) => controller.setIsManualCode(false),
              ),
            ),
            const SizedBox(width: Spacing.x3),
            Expanded(
              child: ChoiceChip(
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.edit_note, size: 16),
                    SizedBox(width: Spacing.x2),
                    Text('Enter Manually'),
                  ],
                ),
                selected: draft.isManualCode,
                showCheckmark: false,
                onSelected: (_) => controller.setIsManualCode(true),
              ),
            ),
          ],
        ),
        if (draft.isManualCode) ...<Widget>[
          const SizedBox(height: Spacing.x4),
          AppTextField(
            label: 'Barcode / Base Serial Code *',
            hint: 'e.g. PRD-DOM-101 or MWS-DOM-000101',
            controller: customCodeController,
            textCapitalization: TextCapitalization.characters,
            onChanged: controller.setCustomCode,
            validator: (String? value) {
              if (draft.isManualCode && (value == null || value.trim().isEmpty)) {
                return 'Please enter a barcode or starting serial code';
              }
              return null;
            },
          ),
          if (generatedSerials.isNotEmpty) ...<Widget>[
            const SizedBox(height: Spacing.x4),
            Container(
              padding: const EdgeInsets.all(Spacing.x3),
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(Spacing.x2),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.qr_code_2, size: 18, color: AppColors.primary),
                      const SizedBox(width: Spacing.x2),
                      Text(
                        'Generated Stock Barcodes (${generatedSerials.length} units):',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.x2),
                  Wrap(
                    spacing: Spacing.x2,
                    runSpacing: Spacing.x2,
                    children: <Widget>[
                      if (generatedSerials.length <= 10)
                        for (final serial in generatedSerials)
                          AppBadge(label: serial, tone: AppBadgeTone.info)
                      else ...<Widget>[
                        for (final serial in generatedSerials.take(4))
                          AppBadge(label: serial, tone: AppBadgeTone.info),
                        AppBadge(
                          label: '+${generatedSerials.length - 8} more',
                          tone: AppBadgeTone.neutral,
                        ),
                        for (final serial in generatedSerials.skip(generatedSerials.length - 4))
                          AppBadge(label: serial, tone: AppBadgeTone.info),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}
