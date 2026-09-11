import 'package:flutter/material.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/app_badge.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../domain/models/catalog_product.dart';
import '../category_label.dart';
import 'catalogue_image.dart';

/// The measurements the catalogue grid and its skeleton must agree on.
///
/// They live beside the card rather than at each call site because the two
/// grids have to produce identical tiles: if the placeholder is a different
/// height, the whole page jumps the moment the real data lands.
abstract final class CatalogueGridMetrics {
  /// Width of the image area on a card divided by its height.
  static const double imageAspectRatio = 4 / 3;

  /// Below this, two columns are too narrow to read a price in.
  static const double _twoColumnMinWidth = 360;

  /// The part of the details block that does not grow with the text scale.
  ///
  /// Card padding above and below, the three gaps between the lines, the two
  /// points between the price label and the price, and the badge's own
  /// vertical inset.
  static const double _fixedDetailHeight =
      Spacing.x3 * 2 + Spacing.x1 + Spacing.x2 * 2 + Spacing.x1 * 2 + 2;

  /// How many columns fit across [width].
  static int columnsFor(double width) => width < _twoColumnMinWidth ? 1 : 2;

  /// Width of a single tile inside [width], after gutters and spacing.
  static double tileWidth(double width) {
    final columns = columnsFor(width);
    final available = width - Spacing.x4 * 2 - Spacing.x3 * (columns - 1);
    return available / columns;
  }

  /// Height one tile needs across [width].
  ///
  /// A grid tile cannot grow to fit its child the way a list row can, so the
  /// height has to be known before the text is laid out. It is summed line box
  /// by line box rather than scaled from one measured total, because Android
  /// applies a non-linear curve to large font sizes: asking the scaler to grow
  /// a single number the size of a whole card returns a far smaller multiplier
  /// than the 12pt and 18pt text inside it actually receives, and the card
  /// would then overflow at exactly the accessibility settings this
  /// calculation exists to survive.
  ///
  /// The badge and the price label are each budgeted at two lines: both wrap
  /// in Gujarati, and both wrap in a two-column grid at a large text scale.
  /// When they come back one line the slack lands on the image, which is the
  /// flexible child, so it reads as a slightly taller photograph rather than
  /// as a gap under the price.
  static double tileExtent(BuildContext context, double width) {
    final scaler = MediaQuery.textScalerOf(context);
    final text =
        _lineHeight(scaler, AppTypography.labelLg, lines: 2) +
        _lineHeight(scaler, AppTypography.bodySm) +
        _lineHeight(scaler, AppTypography.labelSm, lines: 2) +
        _lineHeight(scaler, AppTypography.labelSm, lines: 2) +
        _lineHeight(scaler, AppTypography.titleMd);

    final computed = tileWidth(width) / imageAspectRatio + text + _fixedDetailHeight;
    return computed.clamp(280.0, 600.0);
  }

  /// Height of [lines] line boxes of [style] at the system text scale.
  static double _lineHeight(
    TextScaler scaler,
    TextStyle style, {
    int lines = 1,
  }) => scaler.scale(style.fontSize ?? 14.0) * (style.height ?? 1.2) * lines;
}

/// One product in a dealer catalogue grid.
///
/// The card carries exactly one price and says on its face which price that is.
/// There is no second figure here to misquote from a shop floor, and none for
/// either dealer build to leak.
///
/// [priceLabel] arrives already localised rather than being looked up here: the
/// card is the same for a wholesaler and a retailer, and which of the two words
/// belongs above the figure is a decision the role's configuration has already
/// made.
class CatalogueCard extends StatelessWidget {
  /// Creates a catalogue card.
  const CatalogueCard({
    required this.product,
    required this.priceLabel,
    required this.onTap,
    super.key,
  });

  /// The product to render.
  final CatalogProduct product;

  /// The word printed above [CatalogProduct.price].
  final String priceLabel;

  /// Opens the product detail screen.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      button: true,
      label: product.name,
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Flexible so any slack in the computed tile height lands on the
            // photograph, where it reads as a slightly taller image rather than
            // as a gap under the price.
            Expanded(child: _ImageArea(product: product)),
            Padding(
              padding: const EdgeInsets.all(Spacing.x3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: Spacing.x1),
                  // The code stands in when there is no model number, so this
                  // line is never blank and the tiles in a row stay aligned.
                  Text(
                    product.modelNumber ?? product.productCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: Spacing.x2),
                  AppBadge(
                    label: product.category.catalogueLabel(l10n),
                    tone: AppBadgeTone.info,
                  ),
                  const SizedBox(height: Spacing.x2),
                  Text(
                    priceLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Shrunk rather than ellipsised: half a price is worse than a
                  // small one, and a narrow column at a large text scale is
                  // exactly where a rupee figure runs out of room.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      AppFormat.rupees(product.price),
                      maxLines: 1,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageArea extends StatelessWidget {
  const _ImageArea({required this.product});

  final CatalogProduct product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.card),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // A dimmed photo is what reads as unavailable from arm length,
          // before the badge has been focused on at all.
          Opacity(
            opacity: product.inStock ? 1.0 : 0.4,
            child: CatalogueImage(storagePath: product.primaryImagePath),
          ),
          if (!product.inStock)
            Positioned(
              left: Spacing.x2,
              right: Spacing.x2,
              top: Spacing.x2,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                // The badge fill is a ten per cent tint, which disappears over
                // a photograph. The opaque pill behind it is what keeps the
                // most important word on the card legible.
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: AppBadge(
                    label: context.l10n.badgeOutOfStock,
                    tone: AppBadgeTone.danger,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
