import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_skeleton.dart';

/// Placeholder shaped like the real product list.
///
/// The blocks match the card layout so nothing jumps when the data lands.
class ProductListSkeleton extends StatelessWidget {
  /// Creates the placeholder list.
  const ProductListSkeleton({super.key, this.rows = 5});

  /// How many placeholder cards to draw.
  final int rows;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(Spacing.x4),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows,
        separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
        itemBuilder: (_, __) => const AppCard(
          padding: EdgeInsets.all(Spacing.x3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppSkeleton(width: 72, height: 72),
              SizedBox(width: Spacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppSkeleton(width: 180),
                    SizedBox(height: Spacing.x2),
                    AppSkeleton(width: 100, height: 10),
                    SizedBox(height: Spacing.x3),
                    AppSkeleton(width: 140, height: 12),
                    SizedBox(height: Spacing.x3),
                    AppSkeleton(width: 200, height: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
