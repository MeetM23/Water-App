import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_snackbar.dart';

/// Displays the permanent product code with a one-tap copy button.
class BarcodeBlock extends StatelessWidget {
  /// Creates the barcode block.
  const BarcodeBlock({required this.productCode, super.key});

  /// The code defined by the Admin.
  final String productCode;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: productCode));
    if (context.mounted) {
      AppSnackbar.success(context, context.l10n.createdCopied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.createdCodeLabel,
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.x2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.x3,
              vertical: Spacing.x2,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(Spacing.x2),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.tag_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: Spacing.x2),
                Expanded(
                  child: SelectableText(
                    productCode,
                    style: AppTypography.mono.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _copy(context),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: l10n.actionCopy,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
