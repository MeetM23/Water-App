import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Semantic colour of an [AppSnackbar].
enum AppSnackbarTone {
  /// Neutral confirmation of something that happened.
  neutral,

  /// A completed action.
  success,

  /// A problem the user should notice but that did not stop them.
  error,
}

/// Transient confirmations shown at the bottom of the screen.
///
/// Snackbars are for acknowledging something that already succeeded. They are
/// never used to report a load failure, which is what [AppErrorState] is for.
abstract final class AppSnackbar {
  /// Shows a neutral message.
  static void show(BuildContext context, String message) =>
      _show(context, message, AppSnackbarTone.neutral);

  /// Shows a success message with a tick.
  static void success(BuildContext context, String message) =>
      _show(context, message, AppSnackbarTone.success);

  /// Shows an error message with a warning mark.
  static void error(BuildContext context, String message) =>
      _show(context, message, AppSnackbarTone.error);

  static void _show(
    BuildContext context,
    String message,
    AppSnackbarTone tone,
  ) {
    final (IconData icon, Color accent) = switch (tone) {
      AppSnackbarTone.neutral => (
        Icons.info_outline_rounded,
        AppColors.primaryTint,
      ),
      AppSnackbarTone.success => (
        Icons.check_circle_outline_rounded,
        AppColors.success,
      ),
      AppSnackbarTone.error => (Icons.error_outline_rounded, AppColors.danger),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: Spacing.x3),
              Expanded(child: Text(message)),
            ],
          ),
          duration: const Duration(seconds: 4),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controlAll,
          ),
        ),
      );
  }
}
