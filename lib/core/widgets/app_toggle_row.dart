import 'package:flutter/material.dart';

import '../extensions/build_context_x.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A labelled switch with an explanatory line underneath.
///
/// The helper text is not decoration: a toggle that changes what dealers can
/// see needs to say so at the point of decision.
class AppToggleRow extends StatelessWidget {
  /// Creates a toggle row.
  const AppToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.helperText,
  });

  /// What the toggle controls.
  final String label;

  /// Current state.
  final bool value;

  /// Called with the new state. Null renders the row disabled.
  final ValueChanged<bool>? onChanged;

  /// One line explaining the consequence of turning it on.
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null;

    return InkWell(
      onTap: isEnabled ? () => onChanged!(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.x2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: isEnabled ? AppColors.ink : AppColors.disabledInk,
                    ),
                  ),
                  if (helperText != null) ...<Widget>[
                    const SizedBox(height: Spacing.x1),
                    Text(
                      helperText!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Spacing.x4),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
