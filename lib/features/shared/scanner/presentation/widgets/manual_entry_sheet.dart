import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/product_code.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../domain/models/catalog_product.dart';
import '../../application/scanner_controller.dart';

/// Typing a product code when the camera cannot read it.
///
/// Labels get scuffed, soaked and wrapped around curved bottles, and the
/// dealer holding one of those still needs the price. The format check runs
/// here, offline, so a typo costs a keystroke rather than a round trip, and
/// the sheet stays open on a bad code because the fix is almost always one
/// character.
class ManualEntrySheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const ManualEntrySheet({super.key});

  /// Opens the sheet, returning the product the typed code resolved to.
  static Future<CatalogProduct?> show(BuildContext context) =>
      showModalBottomSheet<CatalogProduct>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const ManualEntrySheet(),
      );

  @override
  ConsumerState<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends ConsumerState<ManualEntrySheet> {
  final TextEditingController _controller = TextEditingController();

  String? _error;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String _) {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final l10n = context.l10n;
    final code = ProductCode.normalise(_controller.text);
    if (code == null) {
      unawaited(HapticFeedback.heavyImpact());
      setState(() => _error = l10n.scanInvalidCode);
      return;
    }

    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    final outcome = await ref
        .read(scannerControllerProvider.notifier)
        .resolve(code);

    if (!mounted) {
      return;
    }

    switch (outcome) {
      case ScanMatched(:final product):
        // The sheet hands the product back rather than navigating itself, so
        // the scan is logged and the route pushed in exactly one place no
        // matter which way the code arrived.
        Navigator.of(context).pop(product);
      case ScanUnitMatched(:final unit):
        if (mounted) {
          Navigator.of(context).pop();
          context.push('/unit/${unit.serialNumber}');
        }
      case ScanRejected(:final reason):
        unawaited(HapticFeedback.heavyImpact());
        setState(() {
          _error = reason.message(l10n);
          _isSubmitting = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: Spacing.x5,
          top: Spacing.x2,
          right: Spacing.x5,
          bottom: Spacing.x5 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        // Scrollable because the keyboard is always up here: on a short phone
        // at the largest system text size the field, its help line and the
        // button together are taller than what the keyboard leaves behind.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.scanManualTitle,
                style: context.textTheme.titleMedium?.copyWith(
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: Spacing.x5),
              AppTextField(
                label: l10n.createdCodeLabel,
                controller: _controller,
                hint: l10n.scanManualHint,
                helperText: l10n.scanManualHelp,
                prefixIcon: Icons.qr_code_2_rounded,
                maxLength: ProductCode.length,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                inputFormatters: const <TextInputFormatter>[
                  _UpperCaseFormatter(),
                ],
                isEnabled: !_isSubmitting,
                onChanged: _handleChanged,
                onSubmitted: (String _) => unawaited(_submit()),
              ),
              if (error != null) ...<Widget>[
                const SizedBox(height: Spacing.x2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: Spacing.x2),
                    Expanded(
                      child: Text(
                        error,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: Spacing.x5),
              AppButton(
                label: l10n.actionContinue,
                onPressed: () => unawaited(_submit()),
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Upper-cases the field as the dealer types.
///
/// The printed code is upper case and its check character is computed over
/// upper-case text. Silently accepting lower case and normalising it later
/// would leave the dealer comparing what is on screen with what is on the
/// label and finding two different things.
class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => TextEditingValue(
    text: newValue.text.toUpperCase(),
    selection: newValue.selection,
  );
}
