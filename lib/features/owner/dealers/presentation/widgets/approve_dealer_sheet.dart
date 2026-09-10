import 'package:flutter/material.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/extensions/enum_labels.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../domain/enums/user_role.dart';
import '../../../../../domain/models/profile.dart';

/// Confirms an approval, and lets the owner change the role first.
///
/// The dealer picked their own role at sign-up, and that choice decides which
/// price list they see for the life of the account. A dealer who ticks
/// "wholesaler" to get better pricing is the expected case, not the unusual
/// one, so the sheet opens on what they asked for, says so plainly, and makes
/// changing it a single tap. It never approves on the strength of the tap that
/// opened it.
class ApproveDealerSheet extends StatefulWidget {
  /// Creates the sheet.
  const ApproveDealerSheet({required this.profile, super.key});

  /// The dealer being approved.
  final Profile profile;

  /// Opens the sheet, returning the chosen role or null if cancelled.
  static Future<UserRole?> show(
    BuildContext context, {
    required Profile profile,
  }) => showModalBottomSheet<UserRole>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ApproveDealerSheet(profile: profile),
  );

  @override
  State<ApproveDealerSheet> createState() => _ApproveDealerSheetState();
}

class _ApproveDealerSheetState extends State<ApproveDealerSheet> {
  late UserRole _role = widget.profile.role;

  /// The roles a dealer may hold. Owner is deliberately absent: it is not a
  /// role anybody can be approved into from this screen.
  static const List<UserRole> _selectable = <UserRole>[
    UserRole.wholesaler,
    UserRole.retailer,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final requested = widget.profile.role;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.approveSheetTitle(widget.profile.firmName),
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: Spacing.x2),
            Text(
              l10n.approveSheetBody(requested.label(l10n).toLowerCase()),
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (requested == UserRole.wholesaler) ...<Widget>[
              const SizedBox(height: Spacing.x4),
              Container(
                padding: const EdgeInsets.all(Spacing.x3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.10),
                  borderRadius: AppRadius.controlAll,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: Spacing.x2),
                    Expanded(
                      child: Text(
                        l10n.approveSheetWarning,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: Spacing.x5),
            for (final role in _selectable)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.x2),
                child: _RoleOption(
                  role: role,
                  isSelected: _role == role,
                  isRequested: requested == role,
                  onTap: () => setState(() => _role = role),
                ),
              ),
            const SizedBox(height: Spacing.x5),
            AppButton(
              label: l10n.approveSheetConfirm(_role.label(l10n)),
              onPressed: () => Navigator.of(context).pop(_role),
            ),
            const SizedBox(height: Spacing.x2),
            AppButton(
              label: l10n.actionCancel,
              onPressed: () => Navigator.of(context).pop(),
              variant: AppButtonVariant.text,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.role,
    required this.isSelected,
    required this.isRequested,
    required this.onTap,
  });

  final UserRole role;
  final bool isSelected;
  final bool isRequested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardAll,
        child: Container(
          padding: const EdgeInsets.all(Spacing.x4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryTint : AppColors.surface,
            borderRadius: AppRadius.cardAll,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                role == UserRole.wholesaler
                    ? Icons.inventory_2_outlined
                    : Icons.storefront_outlined,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: Spacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            role.label(l10n),
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (isRequested) ...<Widget>[
                          const SizedBox(width: Spacing.x2),
                          Text(
                            '(${l10n.requestedRole.toLowerCase()})',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role == UserRole.wholesaler
                          ? l10n.roleWholesalerHelp
                          : l10n.roleRetailerHelp,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
