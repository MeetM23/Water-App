import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// The visual weight of an [AppButton].
enum AppButtonVariant {
  /// Filled brand blue. One per screen, for the main action.
  primary,

  /// Outlined. For secondary actions that sit beside a primary one.
  secondary,

  /// Filled red. For actions that delete or revoke.
  danger,

  /// Label only. For tertiary actions and links.
  text,
}

/// The only button in the app.
///
/// While [isLoading] is true the button paints a spinner in place of its label
/// and refuses taps, so a double tap cannot submit a form twice.
class AppButton extends StatelessWidget {
  /// Creates a button.
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
  });

  /// Text shown on the button.
  final String label;

  /// Tap handler. A null handler renders the disabled state.
  final VoidCallback? onPressed;

  /// Visual weight.
  final AppButtonVariant variant;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the button is waiting on an in-flight operation.
  final bool isLoading;

  /// Whether the button fills the width available to it.
  final bool isExpanded;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final child = _buildChild(context);
    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        child: child,
      ),
      AppButtonVariant.danger => ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: AppColors.surface,
          disabledBackgroundColor: AppColors.disabledFill,
          disabledForegroundColor: AppColors.disabledInk,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.x5),
          textStyle: Theme.of(context).textTheme.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controlAll,
          ),
        ),
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: _isEnabled ? onPressed : null,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: _isEnabled ? onPressed : null,
        child: child,
      ),
    };

    return isExpanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: switch (variant) {
            AppButtonVariant.primary ||
            AppButtonVariant.danger => AppColors.surface,
            AppButtonVariant.secondary => AppColors.ink,
            AppButtonVariant.text => AppColors.primary,
          },
        ),
      );
    }

    if (icon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 18),
        const SizedBox(width: Spacing.x2),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
