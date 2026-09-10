import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../domain/models/price_validation.dart';
import '../../../../../domain/models/product_draft.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../application/product_form_controller.dart';

/// Wholesale, retail and MRP, with the dealer margin computed live.
///
/// The margin chip is the number the owner actually reasons about when pricing,
/// so it updates on every keystroke rather than after saving.
class PricingSection extends ConsumerWidget {
  /// Creates the pricing section.
  const PricingSection({
    required this.productId,
    required this.draft,
    required this.mrpController,
    required this.wholesaleController,
    required this.retailController,
    super.key,
  });

  /// Which form instance this belongs to.
  final String? productId;

  /// The draft being edited.
  final ProductDraft draft;

  /// Controller for the MRP field.
  final TextEditingController mrpController;

  /// Controller for the wholesale field.
  final TextEditingController wholesaleController;

  /// Controller for the retail field.
  final TextEditingController retailController;

  static final List<TextInputFormatter> _moneyFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(
      productFormControllerProvider(productId).notifier,
    );
    final validation = PriceRules.check(
      wholesale: draft.wholesalePrice,
      retail: draft.retailPrice,
      mrp: draft.mrp,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppTextField(
          label: l10n.fieldMrpLabel,
          controller: mrpController,
          trailingLabel: l10n.fieldOptional,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: _moneyFormatters,
          prefixIcon: Icons.sell_outlined,
          onChanged: controller.setMrp,
          validator: (_) => _mrpError(validation, l10n),
        ),
        const SizedBox(height: Spacing.x5),
        AppTextField(
          label: l10n.fieldWholesaleLabel,
          controller: wholesaleController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: _moneyFormatters,
          prefixIcon: Icons.storefront_outlined,
          onChanged: controller.setWholesalePrice,
          validator: (_) => _wholesaleError(validation, l10n),
        ),
        const SizedBox(height: Spacing.x5),
        AppTextField(
          label: l10n.fieldRetailLabel,
          controller: retailController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: _moneyFormatters,
          prefixIcon: Icons.local_offer_outlined,
          onChanged: controller.setRetailPrice,
          validator: (_) => _retailError(validation, l10n),
        ),
        const SizedBox(height: Spacing.x5),
        _MarginChip(draft: draft),
        for (final warning in validation.warnings) ...<Widget>[
          const SizedBox(height: Spacing.x3),
          _WarningRow(message: _warningLabel(context, warning)),
        ],
      ],
    );
  }

  /// Both MRP faults block the save, so both have to be visible. Leaving
  /// `mrpNotPositive` unmapped disabled the button with nothing on screen
  /// explaining why.
  String? _mrpError(PriceValidation validation, AppLocalizations l10n) {
    if (validation.errors.contains(PriceError.mrpMalformed) ||
        validation.errors.contains(PriceError.mrpNotPositive)) {
      return l10n.priceErrorNotPositive;
    }
    return null;
  }

  String? _wholesaleError(PriceValidation validation, AppLocalizations l10n) {
    if (validation.errors.contains(PriceError.wholesaleMissing)) {
      return l10n.validationRequired(l10n.fieldWholesaleLabel);
    }
    if (validation.errors.contains(PriceError.wholesaleNotPositive)) {
      return l10n.priceErrorNotPositive;
    }
    return null;
  }

  String? _retailError(PriceValidation validation, AppLocalizations l10n) {
    if (validation.errors.contains(PriceError.retailMissing)) {
      return l10n.validationRequired(l10n.fieldRetailLabel);
    }
    if (validation.errors.contains(PriceError.retailNotPositive)) {
      return l10n.priceErrorNotPositive;
    }
    if (validation.errors.contains(PriceError.retailBelowWholesale)) {
      return l10n.priceErrorRetailBelowWholesale;
    }
    return null;
  }

  static String _warningLabel(BuildContext context, PriceWarning warning) {
    final l10n = context.l10n;
    return switch (warning) {
      PriceWarning.wholesaleAboveMrp ||
      PriceWarning.retailAboveMrp => l10n.priceWarningAboveMrp,
      PriceWarning.zeroMargin => l10n.priceWarningZeroMargin,
    };
  }
}

class _MarginChip extends StatelessWidget {
  const _MarginChip({required this.draft});

  final ProductDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final margin = draft.dealerMargin;
    final percent = draft.dealerMarginPercent;

    final hasMargin = margin != null && percent != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.x4),
      decoration: BoxDecoration(
        color: hasMargin ? AppColors.primaryTint : AppColors.disabledFill,
        borderRadius: AppRadius.controlAll,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.trending_up_rounded,
            size: 20,
            color: hasMargin ? AppColors.primaryDark : AppColors.disabledInk,
          ),
          const SizedBox(width: Spacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.labelMargin,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasMargin
                      ? l10n.marginChip(
                          AppFormat.rupees(margin),
                          percent.toStringAsFixed(1),
                        )
                      : l10n.marginUnavailable,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: hasMargin
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningRow extends StatelessWidget {
  const _WarningRow({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Icon(
          Icons.warning_amber_rounded,
          size: 18,
          color: AppColors.warning,
        ),
        const SizedBox(width: Spacing.x2),
        Expanded(
          child: Text(
            message,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }
}
