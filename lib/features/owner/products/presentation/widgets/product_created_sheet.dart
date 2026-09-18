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
import '../../../../../data/repositories/supabase_product_repository.dart';
import '../../../../../domain/models/business_settings.dart';
import '../../../../../domain/models/product.dart';
import '../../../labels/data/label_pdf_builder.dart';
import '../../../labels/domain/label_sheet_spec.dart';
import '../../../labels/domain/product_label_tracker.dart';
import '../../../settings/application/business_settings_controller.dart';
import 'barcode_block.dart';

enum _PrintMode { newLabels, allLabels, custom }

/// Shown after a product is created or restocked.
class ProductCreatedSheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const ProductCreatedSheet({
    required this.product,
    this.previousStock = 0,
    super.key,
  });

  /// The product that was created or updated.
  final Product product;

  /// Stock quantity before this edit/restock.
  final int previousStock;

  /// Opens the sheet for [product].
  static Future<void> show(
    BuildContext context, {
    required Product product,
    int previousStock = 0,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => ProductCreatedSheet(
          product: product,
          previousStock: previousStock,
        ),
      );

  @override
  ConsumerState<ProductCreatedSheet> createState() =>
      _ProductCreatedSheetState();
}

class _ProductCreatedSheetState extends ConsumerState<ProductCreatedSheet> {
  bool _isBusy = false;
  _PrintMode _mode = _PrintMode.newLabels;
  int _customQuantity = 1;
  late ProductLabelTracker _tracker;

  @override
  void initState() {
    super.initState();
    _tracker = ProductLabelTracker.fromProduct(widget.product);
    final totalQty = widget.product.stockQuantity ?? 1;
    final prevQty = widget.previousStock;
    final addedQty = (totalQty - prevQty).clamp(0, totalQty);
    _customQuantity = addedQty > 0 ? addedQty : (totalQty > 0 ? totalQty : 1);
  }

  List<String> _resolveSerialsToPrint() {
    switch (_mode) {
      case _PrintMode.newLabels:
        final available = _tracker.newLabelsAvailable;
        if (available > 0) {
          return _tracker.previewNewLabels(available);
        }
        return _tracker.getAllLabels();
      case _PrintMode.allLabels:
        return _tracker.getAllLabels();
      case _PrintMode.custom:
        return _tracker.getCustomLabels(_customQuantity);
    }
  }

  Future<Uint8List?> _buildSingleLabelSheet() async {
    final product = widget.product;
    final serialsToPrint = _resolveSerialsToPrint();

    return LabelPdfBuilder.build(
      items: <LabelJobItem>[
        LabelJobItem(
          product: product,
          serialNumbers: serialsToPrint,
        ),
      ],
      spec: LabelSheets.newProductDefault,
      business:
          ref.read(businessSettingsControllerProvider).valueOrNull ??
          const BusinessSettings(businessName: 'Maruti Water Solution'),
    );
  }

  Future<void> _persistPrintedState() async {
    try {
      if (_mode == _PrintMode.newLabels && _tracker.newLabelsAvailable > 0) {
        final allocation = _tracker.allocateLabels(_tracker.newLabelsAvailable);
        await ref
            .read(productRepositoryProvider)
            .updateLabelSequence(widget.product.id, allocation.tracker.toJson());
        if (mounted) {
          setState(() {
            _tracker = allocation.tracker;
          });
        }
      }
    } catch (e) {
      AppLog.warn('Failed to persist label printed state: $e');
    }
  }

  Future<void> _print() async {
    setState(() => _isBusy = true);
    try {
      final bytes = await _buildSingleLabelSheet();
      if (bytes == null) {
        return;
      }
      await Printing.layoutPdf(onLayout: (_) async => bytes);
      await _persistPrintedState();
    } on Object catch (error, stackTrace) {
      AppLog.error('Printing product labels failed', error, stackTrace);
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
      await _persistPrintedState();
    } on Object catch (error, stackTrace) {
      AppLog.error('Sharing product labels failed', error, stackTrace);
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
    final totalQty = widget.product.stockQuantity ?? 1;
    final prevQty = widget.previousStock;
    final addedQty = (totalQty - prevQty).clamp(0, totalQty);
    final isRestock = prevQty > 0 && addedQty > 0;

    final availableNew = _tracker.newLabelsAvailable;
    final allLabels = _tracker.getAllLabels();
    final newCount = availableNew > 0 ? availableNew : (addedQty > 0 ? addedQty : totalQty);
    final allCount = allLabels.length;

    final activeSerials = _resolveSerialsToPrint();
    final serialPreview = activeSerials.isEmpty
        ? widget.product.productCode
        : (activeSerials.length == 1
            ? activeSerials.first
            : '${activeSerials.first} → ${activeSerials.last}');

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
              isRestock ? 'Product Restocked!' : l10n.createdTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: Spacing.x2),
            Text(
              isRestock
                  ? 'Added $addedQty new units to stock (Total: $totalQty units).'
                  : l10n.createdBody,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.x4),
            Text(
              'PRINT LABELS',
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.x2),
            Wrap(
              spacing: Spacing.x2,
              runSpacing: Spacing.x2,
              children: <Widget>[
                ChoiceChip(
                  label: Text('Print New Labels ($newCount)'),
                  selected: _mode == _PrintMode.newLabels,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _mode = _PrintMode.newLabels),
                ),
                ChoiceChip(
                  label: Text('Print All Labels ($allCount)'),
                  selected: _mode == _PrintMode.allLabels,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _mode = _PrintMode.allLabels),
                ),
                ChoiceChip(
                  label: const Text('Custom Quantity'),
                  selected: _mode == _PrintMode.custom,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _mode = _PrintMode.custom),
                ),
              ],
            ),
            if (_mode == _PrintMode.custom) ...<Widget>[
              const SizedBox(height: Spacing.x3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _customQuantity > 1
                        ? () => setState(() => _customQuantity--)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.x3),
                    child: Text(
                      '$_customQuantity Labels',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _customQuantity < 500
                        ? () => setState(() => _customQuantity++)
                        : null,
                  ),
                ],
              ),
            ],
            const SizedBox(height: Spacing.x4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.x3,
                vertical: Spacing.x2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.qr_code_2_rounded,
                    size: 18,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: Spacing.x2),
                  Flexible(
                    child: Text(
                      'Series: $serialPreview (${activeSerials.length} labels)',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.x4),
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

