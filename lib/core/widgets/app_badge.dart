import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Semantic colour of an [AppBadge].
enum AppBadgeTone {
  /// Grey. Inert facts.
  neutral,

  /// Blue. Informational, on-brand.
  info,

  /// Green. Approved, in stock, healthy.
  success,

  /// Amber. Pending, awaiting action.
  warning,

  /// Red. Rejected, suspended, out of stock.
  danger,
}

/// A small pill used for statuses and counts.
class AppBadge extends StatelessWidget {
  /// Creates a badge.
  const AppBadge({
    required this.label,
    super.key,
    this.tone = AppBadgeTone.neutral,
    this.icon,
  });

  /// Badge text.
  final String label;

  /// Semantic colour.
  final AppBadgeTone tone;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (Color foreground, Color background) = switch (tone) {
      AppBadgeTone.neutral => (AppColors.textSecondary, AppColors.disabledFill),
      AppBadgeTone.info => (AppColors.primaryDark, AppColors.primaryTint),
      AppBadgeTone.success => (AppColors.success, const Color(0x1A0E9F6E)),
      AppBadgeTone.warning => (AppColors.warning, const Color(0x1AD97706)),
      AppBadgeTone.danger => (AppColors.danger, const Color(0x1ADC2626)),
    };

    // A badge sits inside a Wrap or a Row that has already decided how much
    // width there is. At a large system text scale a label such as
    // "Asked for: Wholesaler" is wider than that, so the text has to be free
    // to shrink: without the Flexible the Row overflows and paints a stripe
    // across the card.
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.x3,
        vertical: Spacing.x1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: Spacing.x1),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
