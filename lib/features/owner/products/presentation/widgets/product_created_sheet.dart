import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../../../domain/models/business_settings.dart';
import '../../../../../domain/models/product.dart';
import '../../../labels/data/label_pdf_builder.dart';
import '../../../labels/domain/label_sheet_spec.dart';
import '../../../settings/application/business_settings_controller.dart';
import 'barcode_block.dart';

/// Shown once, immediately after a product is created.
///
/// The moment a code exists is the moment the owner wants to print it, so the
/// label actions are here rather than three screens away.
class ProductCreatedSheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const ProductCreatedSheet({required this.product, super.key});

  /// The product that was just created.
  final Product product;

  /// Opens the sheet for [product].
  static Future<void> show(BuildContext context, {required Product product}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => ProductCreatedSheet(product: product),
      );

  @override
  ConsumerState<ProductCreatedSheet> createState() =>
      _ProductCreatedSheetState();
}

class _ProductCreatedSheetState extends ConsumerState<ProductCreatedSheet> {
  bool _isBusy = false;

  Future<Uint8List?> _buildSingleLabelSheet() async {
    final product = widget.product;
    final stockQty = product.stockQuantity ?? 1;

    List<String> serials = <String>[product.productCode];
    if (stockQty > 1) {
      final match = RegExp(r'^(.*?)(\d+)$').firstMatch(product.productCode);
      if (match != null) {
        final prefix = match.group(1)!;
        final numStr = match.group(2)!;
        final startNum = int.tryParse(numStr) ?? 1;
        final padLength = numStr.length;
        serials = <String>[
          for (var i = 0; i < stockQty; i++)
            '$prefix${(startNum + i).toString().padLeft(padLength, '0')}'
        ];
      } else {
        final padLength = stockQty >= 100 ? 3 : 2;
        serials = <String>[
          for (var i = 0; i < stockQty; i++)
            '${product.productCode}-${(i + 1).toString().padLeft(padLength, '0')}'
        ];
      }
    }

    return LabelPdfBuilder.build(
      items: <LabelJobItem>[
        LabelJobItem(
          product: product,
          serialNumbers: serials,
        ),
      ],
      spec: LabelSheets.newProductDefault,
      business:
          ref.read(businessSettingsControllerProvider).valueOrNull ??
          const BusinessSettings(businessName: 'Maruti Water Solution'),
    );
  }

  Future<void> _print() async {
    setState(() => _isBusy = true);
    try {
      final bytes = await _buildSingleLabelSheet();
      if (bytes == null) {
        return;
      }
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } on Object catch (error, stackTrace) {
      AppLog.error('Printing a new product label failed', error, stackTrace);
      if (mounted) {
        AppSnackbar.error(context, context.l10n.labelsGenerateFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _share() async {
    setState(() => _isBusy = true);
    try {
      final bytes = await _buildSingleLabelSheet();
      if (bytes == null) {
        return;
      }
      await Share.shareXFiles(<XFile>[
        XFile.fromData(
          bytes,
          name: '${widget.product.productCode}.pdf',
          mimeType: 'application/pdf',
        ),
      ]);
    } on Object catch (error, stackTrace) {
      AppLog.error('Sharing a new product label failed', error, stackTrace);
      if (mounted) {
        AppSnackbar.error(context, context.l10n.labelsGenerateFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Align(
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 44,
              ),
            ),
            const SizedBox(height: Spacing.x4),
            Text(
              l10n.createdTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: Spacing.x2),
            Text(
              l10n.createdBody,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.x6),
            BarcodeBlock(productCode: widget.product.productCode),
            const SizedBox(height: Spacing.x6),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    label: l10n.actionPrint,
                    onPressed: _print,
                    icon: Icons.print_outlined,
                    isLoading: _isBusy,
                  ),
                ),
                const SizedBox(width: Spacing.x3),
                Expanded(
                  child: AppButton(
                    label: l10n.actionShare,
                    onPressed: _share,
                    icon: Icons.ios_share_rounded,
                    variant: AppButtonVariant.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.x3),
            AppButton(
              label: l10n.actionDone,
              onPressed: () => Navigator.of(context).pop(),
              variant: AppButtonVariant.text,
            ),
          ],
        ),
      ),
    );
  }
}
