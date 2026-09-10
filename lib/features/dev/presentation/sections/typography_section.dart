import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/gallery_section.dart';

/// Type scale, palette and spacing specimens.
class TypographySection extends StatelessWidget {
  /// Creates the foundations section.
  const TypographySection({super.key});

  static const List<(String, TextStyle)> _scale = <(String, TextStyle)>[
    ('displayLg', AppTypography.displayLg),
    ('titleLg', AppTypography.titleLg),
    ('titleMd', AppTypography.titleMd),
    ('bodyLg', AppTypography.bodyLg),
    ('bodyMd', AppTypography.bodyMd),
    ('bodySm', AppTypography.bodySm),
    ('labelLg', AppTypography.labelLg),
    ('labelSm', AppTypography.labelSm),
    ('mono', AppTypography.mono),
  ];

  static const List<(String, Color)> _palette = <(String, Color)>[
    ('primary', AppColors.primary),
    ('primaryDark', AppColors.primaryDark),
    ('primaryTint', AppColors.primaryTint),
    ('ink', AppColors.ink),
    ('textSecondary', AppColors.textSecondary),
    ('background', AppColors.background),
    ('border', AppColors.border),
    ('success', AppColors.success),
    ('warning', AppColors.warning),
    ('danger', AppColors.danger),
  ];

  static const List<(String, double)> _spacing = <(String, double)>[
    ('x1', Spacing.x1),
    ('x2', Spacing.x2),
    ('x3', Spacing.x3),
    ('x4', Spacing.x4),
    ('x5', Spacing.x5),
    ('x6', Spacing.x6),
    ('x8', Spacing.x8),
    ('x10', Spacing.x10),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GallerySection(
          title: 'Type scale',
          children: <Widget>[
            for (final (String name, TextStyle style) in _scale)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Maruti Water  મારુતિ વોટર  ₹1,25,000',
                      style: style.copyWith(color: AppColors.ink),
                    ),
                  ],
                ),
              ),
          ],
        ),
        GallerySection(
          title: 'Palette',
          children: <Widget>[
            Wrap(
              spacing: Spacing.x3,
              runSpacing: Spacing.x3,
              children: <Widget>[
                for (final (String name, Color color) in _palette)
                  SizedBox(
                    width: 96,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: AppRadius.controlAll,
                            border: AppShadows.hairline,
                          ),
                        ),
                        const SizedBox(height: Spacing.x1),
                        Text(
                          name,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'Spacing grid',
          children: <Widget>[
            for (final (String name, double value) in _spacing)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.x2),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 40,
                      child: Text(
                        name,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      height: 12,
                      width: value,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.pillAll,
                      ),
                    ),
                    const SizedBox(width: Spacing.x2),
                    Text(
                      '${value.toInt()}dp',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
