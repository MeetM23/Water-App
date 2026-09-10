import 'package:flutter/material.dart';

import '../extensions/build_context_x.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

/// Confirmation prompt shown before an action that cannot be undone.
///
/// The message must name the specific item being acted on. "Delete this?" is
/// not acceptable; "Delete Aqua Grand Domestic RO Purifier?" is.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog._({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
  });

  /// Dialog headline.
  final String title;

  /// Body copy naming the affected item.
  final String message;

  /// Label of the confirming button.
  final String confirmLabel;

  /// Label of the dismissing button.
  final String cancelLabel;

  /// Renders the confirm button in the danger variant.
  final bool isDestructive;

  /// Shows the dialog and resolves true only if the user confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AppConfirmDialog._(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel ?? dialogContext.l10n.actionCancel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(
        Spacing.x6,
        0,
        Spacing.x6,
        Spacing.x5,
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton(
                label: cancelLabel,
                onPressed: () => Navigator.of(context).pop(false),
                variant: AppButtonVariant.secondary,
              ),
            ),
            const SizedBox(width: Spacing.x3),
            Expanded(
              child: AppButton(
                label: confirmLabel,
                onPressed: () => Navigator.of(context).pop(true),
                variant: isDestructive
                    ? AppButtonVariant.danger
                    : AppButtonVariant.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
