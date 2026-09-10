import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../extensions/build_context_x.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// The Maruti Water Solution lockup: a droplet tile beside the company name.
///
/// One definition serves the signed-out screens and every owner app bar, so
/// the mark cannot drift between them.
class BrandWordmark extends StatelessWidget {
  /// Creates the full lockup, with the town beneath the name.
  const BrandWordmark({super.key}) : isCompact = false;

  /// Creates the compact lockup used inside an app bar.
  const BrandWordmark.compact({super.key}) : isCompact = true;

  /// Whether to draw the smaller single-line variant.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final tileSize = isCompact ? 28.0 : 44.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: tileSize,
          width: tileSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: isCompact
                ? const BorderRadius.all(Radius.circular(8))
                : AppRadius.cardAll,
          ),
          child: Icon(
            Icons.water_drop_rounded,
            color: AppColors.surface,
            size: isCompact ? 16 : 24,
          ),
        ),
        SizedBox(width: isCompact ? Spacing.x2 : Spacing.x3),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AppConfig.companyName,
                overflow: TextOverflow.ellipsis,
                style:
                    (isCompact
                            ? context.textTheme.titleSmall
                            : context.textTheme.titleMedium)
                        ?.copyWith(color: AppColors.ink),
              ),
              if (!isCompact)
                Text(
                  AppConfig.companyLocation,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
