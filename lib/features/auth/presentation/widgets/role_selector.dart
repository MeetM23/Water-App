import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/enums/user_role.dart';

/// Lets a new dealer pick between wholesaler and retailer.
///
/// Owner is deliberately absent. Even if it were offered, handle_new_user() in
/// the database clamps the requested role to these two, so the owner role
/// cannot be obtained by editing the request.
class RoleSelector extends StatelessWidget {
  /// Creates a role selector.
  const RoleSelector({
    required this.value,
    required this.onChanged,
    super.key,
    this.isEnabled = true,
  });

  /// Currently selected role.
  final UserRole value;

  /// Called with the newly selected role.
  final ValueChanged<UserRole> onChanged;

  /// Whether selection is allowed.
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.signupAccountType,
          style: context.textTheme.labelLarge?.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: Spacing.x2),
        _RoleOption(
          title: l10n.roleWholesaler,
          icon: Icons.inventory_2_outlined,
          isSelected: value == UserRole.wholesaler,
          onTap: isEnabled ? () => onChanged(UserRole.wholesaler) : null,
        ),
        const SizedBox(height: Spacing.x3),
        _RoleOption(
          title: l10n.roleRetailer,
          icon: Icons.storefront_outlined,
          isSelected: value == UserRole.retailer,
          onTap: isEnabled ? () => onChanged(UserRole.retailer) : null,
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      label: title,
      child: AppCard(
        onTap: onTap,
        isSelected: isSelected,
        padding: const EdgeInsets.all(Spacing.x4),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: Spacing.x4),
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.ink,
                ),
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
    );
  }
}
