import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

/// What a list shows when it has no rows.
///
/// Every list in this app uses one of these. A blank screen leaves the user
/// unsure whether the app is broken, still loading, or simply empty.
class AppEmptyState extends StatelessWidget {
  /// Creates an empty state.
  const AppEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  /// Illustrative icon shown in a tinted well.
  final IconData icon;

  /// One short line naming what is missing.
  final String title;

  /// One sentence explaining why, in plain language.
  final String message;

  /// Label of the primary action. Omit to render without a button.
  final String? actionLabel;

  /// Primary action handler.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 64,
              width: 64,
              decoration: const BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: AppRadius.cardAll,
              ),
              child: Icon(icon, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: Spacing.x5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: Spacing.x2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: Spacing.x6),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                isExpanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
