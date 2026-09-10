import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_snackbar.dart';

/// Shared layout for the three screens that hold a signed-in user outside the
/// app: pending approval, rejected, and suspended.
///
/// The tone is calm on purpose. These users have done nothing wrong; they are
/// waiting on Maruti Water Solution, and the screen should read that way.
class AccountStatusView extends StatelessWidget {
  /// Creates a status screen body.
  const AccountStatusView({
    required this.icon,
    required this.accent,
    required this.title,
    required this.message,
    required this.onSignOut,
    required this.isSigningOut,
    super.key,
    this.detailLabel,
    this.detailValue,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.isPrimaryActionLoading = false,
  });

  /// Icon shown in the tinted well.
  final IconData icon;

  /// Colour of the icon and its well.
  final Color accent;

  /// Headline.
  final String title;

  /// One paragraph explaining the situation.
  final String message;

  /// Ends the session.
  final VoidCallback onSignOut;

  /// Whether the sign-out request is in flight.
  final bool isSigningOut;

  /// Label above the detail block, such as the registered firm.
  final String? detailLabel;

  /// Value shown in the detail block.
  final String? detailValue;

  /// Label of the screen-specific action, such as checking the status.
  final String? primaryActionLabel;

  /// Handler for the screen-specific action.
  final VoidCallback? onPrimaryAction;

  /// Whether the screen-specific action is in flight.
  final bool isPrimaryActionLoading;

  Future<void> _openWhatsApp(BuildContext context) async {
    final opened = await ContactLauncher.openWhatsApp();
    if (!opened && context.mounted) {
      AppSnackbar.error(context, context.l10n.contactUnavailable);
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.signOutConfirmTitle,
      message: l10n.signOutConfirmBody,
      confirmLabel: l10n.actionSignOut,
      isDestructive: true,
    );
    if (confirmed) {
      onSignOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.x6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    child: Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        borderRadius: AppRadius.cardAll,
                      ),
                      child: Icon(icon, size: 32, color: accent),
                    ),
                  ),
                  const SizedBox(height: Spacing.x6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: Spacing.x3),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (detailLabel != null && detailValue != null) ...<Widget>[
                    const SizedBox(height: Spacing.x6),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            detailLabel!,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: Spacing.x1),
                          Text(
                            detailValue!,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.x8),
                  if (primaryActionLabel != null &&
                      onPrimaryAction != null) ...<Widget>[
                    AppButton(
                      label: primaryActionLabel!,
                      onPressed: onPrimaryAction,
                      icon: Icons.refresh_rounded,
                      isLoading: isPrimaryActionLoading,
                    ),
                    const SizedBox(height: Spacing.x3),
                  ],
                  AppButton(
                    label: l10n.contactWhatsApp,
                    onPressed: () => _openWhatsApp(context),
                    icon: Icons.chat_outlined,
                    variant: AppButtonVariant.secondary,
                  ),
                  const SizedBox(height: Spacing.x3),
                  AppButton(
                    label: l10n.actionSignOut,
                    onPressed: () => _confirmSignOut(context),
                    variant: AppButtonVariant.text,
                    isLoading: isSigningOut,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
