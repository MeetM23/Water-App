import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// A surface with the house elevation: a hairline border plus a soft shadow.
///
/// Material elevation is not used anywhere in this app, because its tinted
/// overlays are what make stock Flutter apps recognisable at a glance.
class AppCard extends StatelessWidget {
  /// Creates a card.
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(Spacing.x4),
    this.onTap,
    this.isSelected = false,
  });

  /// Card contents.
  final Widget child;

  /// Inner padding around [child].
  final EdgeInsetsGeometry padding;

  /// Makes the whole card tappable when provided.
  final VoidCallback? onTap;

  /// Draws the selected treatment: brand border over a tinted fill.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryTint : AppColors.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: onTap == null
          ? content
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppRadius.cardAll,
                child: content,
              ),
            ),
    );
  }
}
