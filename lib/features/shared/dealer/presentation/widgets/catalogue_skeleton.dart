import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_skeleton.dart';
import 'catalogue_card.dart';

/// Placeholder shaped like the catalogue grid.
///
/// A grid, not a list, and measured with [CatalogueGridMetrics] so the tiles
/// land in exactly the positions the real cards will take. Anything else and
/// the first frame of real data throws the page around.
class CatalogueSkeleton extends StatelessWidget {
  /// Creates the placeholder grid.
  const CatalogueSkeleton({super.key, this.tiles = 6});

  /// How many placeholder tiles to draw.
  final int tiles;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final width = constraints.maxWidth;

          return GridView.builder(
            padding: const EdgeInsets.all(Spacing.x4),
            shrinkWrap: true,
            // The placeholder is not something to scroll through; the real
            // grid arrives at the top and that is where the eye should be.
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: CatalogueGridMetrics.columnsFor(width),
              crossAxisSpacing: Spacing.x3,
              mainAxisSpacing: Spacing.x3,
              mainAxisExtent: CatalogueGridMetrics.tileExtent(context, width),
            ),
            itemCount: tiles,
            itemBuilder: (_, __) => const _SkeletonTile(),
          );
        },
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: AppSkeleton(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.card),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Spacing.x3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppSkeleton(height: 12),
                SizedBox(height: Spacing.x2),
                AppSkeleton(width: 72, height: 10),
                SizedBox(height: Spacing.x3),
                AppSkeleton(width: 104, height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
