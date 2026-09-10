import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// A titled block of gallery specimens.
class GallerySection extends StatelessWidget {
  /// Creates a gallery section.
  const GallerySection({
    required this.title,
    required this.children,
    super.key,
  });

  /// Section heading.
  final String title;

  /// Specimens, laid out in a column.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title.toUpperCase(),
          style: context.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: Spacing.x4),
        ...children,
        const SizedBox(height: Spacing.x10),
      ],
    );
  }
}

/// A single specimen with a caption naming the state it demonstrates.
class GallerySpecimen extends StatelessWidget {
  /// Creates a captioned specimen.
  const GallerySpecimen({
    required this.caption,
    required this.child,
    super.key,
  });

  /// What state this specimen shows.
  final String caption;

  /// The widget being demonstrated.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.x5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            caption,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Spacing.x2),
          child,
        ],
      ),
    );
  }
}
