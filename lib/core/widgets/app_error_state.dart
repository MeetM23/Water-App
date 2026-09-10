import 'package:flutter/material.dart';

import '../errors/app_failure.dart';
import '../errors/failure_presentation.dart';
import '../extensions/build_context_x.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

/// What a screen shows when loading failed.
///
/// Plain language and a retry button. No red error widget, no exception text,
/// no bare snackbar: the user is told what went wrong and given the one action
/// that might fix it.
class AppErrorState extends StatelessWidget {
  /// Creates an error state from a repository failure.
  const AppErrorState({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  /// The failure to describe.
  final AppFailure failure;

  /// Runs the failed operation again.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOffline = failure is NetworkFailure;

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
                color: Color(0x14DC2626),
                borderRadius: AppRadius.cardAll,
              ),
              child: Icon(
                isOffline
                    ? Icons.wifi_off_rounded
                    : Icons.error_outline_rounded,
                size: 28,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: Spacing.x5),
            Text(
              failure.title(l10n),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: Spacing.x2),
            Text(
              failure.message(l10n),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.x6),
            AppButton(
              label: l10n.actionRetry,
              onPressed: onRetry,
              icon: Icons.refresh_rounded,
              variant: AppButtonVariant.secondary,
              isExpanded: false,
            ),
          ],
        ),
      ),
    );
  }
}
