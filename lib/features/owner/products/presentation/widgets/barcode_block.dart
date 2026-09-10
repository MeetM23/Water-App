import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_snackbar.dart';

/// The permanent product code, rendered in both symbologies.
///
/// Code 128 is what a shop's handheld laser scanner reads off a printed label.
/// QR is faster and far more forgiving from a phone camera held at an angle,
/// which is how a dealer standing in a warehouse will actually scan it. Both
/// encode the identical string, so either resolves to the same product.
class BarcodeBlock extends StatelessWidget {
  /// Creates the barcode block.
  const BarcodeBlock({required this.productCode, super.key});

  /// The code issued by the database.
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
        children: <Widget>[
          Text(
            l10n.createdCodeLabel,
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Spacing.x2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  productCode,
                  textAlign: TextAlign.center,
                  style: AppTypography.mono.copyWith(
                    fontSize: 20,
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
          const SizedBox(height: Spacing.x5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: _Symbology(
                  caption: l10n.barcodeCode128,
                  child: BarcodeWidget(
                    barcode: Barcode.code128(escapes: false),
                    data: productCode,
                    drawText: false,
                    height: 64,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.x4),
              Expanded(
                flex: 2,
                child: _Symbology(
                  caption: l10n.barcodeQr,
                  child: BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    data: productCode,
                    drawText: false,
                    height: 80,
                    width: 80,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Symbology extends StatelessWidget {
  const _Symbology({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        child,
        const SizedBox(height: Spacing.x2),
        Text(
          caption,
          style: context.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
