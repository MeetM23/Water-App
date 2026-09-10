import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/brand_wordmark.dart';
import '../../../../domain/models/dealer_activity.dart';
import '../../../../domain/models/product.dart';
import '../../../../domain/repositories/product_repository.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../application/dashboard_controller.dart';
import 'widgets/dashboard_card.dart';

/// The owner landing screen.
///
/// Every element answers a question the client actually asks: is anyone
/// waiting on me, what is out of stock, what are dealers scanning, who did I
/// approve last week. Nothing here is decoration, and each section loads and
/// fails on its own so one bad query never blanks the lot.
class DashboardScreen extends ConsumerWidget {
  /// Creates the dashboard.
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: const BrandWordmark.compact()),
      body: RefreshIndicator(
        onRefresh: () async => refreshDashboard(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(Spacing.x4),
          children: <Widget>[
            _Header(label: l10n.dashboardNeedsAttention),
            const _PendingCard(),
            const SizedBox(height: Spacing.x6),
            _Header(label: l10n.dashboardCatalogue),
            const _CatalogueCounts(),
            const SizedBox(height: Spacing.x6),
            _Header(label: l10n.dashboardNetwork),
            const _NetworkCounts(),
            const SizedBox(height: Spacing.x6),
            _Header(label: l10n.dashboardQuickActions),
            const _QuickActions(),
            const SizedBox(height: Spacing.x6),
            _Header(label: l10n.dashboardTopScanned),
            const _TopScanned(),
            const SizedBox(height: Spacing.x6),
            _Header(label: l10n.dashboardRecentlyAdded),
            const _RecentlyAdded(),
            const SizedBox(height: Spacing.x6),
            _Header(label: l10n.dashboardActivity),
            const _ActivityFeed(),
            const SizedBox(height: Spacing.x10),
          ],
        ),
      ),
    );
  }
}

/// Pending approvals. The first thing on the screen because it is the only
/// item that represents somebody waiting on the client to act.
class _PendingCard extends ConsumerWidget {
  const _PendingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return DashboardCard<DealerCounts>(
      value: ref.watch(dealerCountsCardProvider),
      onRetry: () => ref.invalidate(dealerCountsCardProvider),
      skeletonHeight: 72,
      builder: (BuildContext context, DealerCounts counts) {
        final waiting = counts.pending > 0;

        return AppCard(
          onTap: () => context.push(AppRoutes.ownerDealerRequests),
          padding: const EdgeInsets.all(Spacing.x4),
          child: Row(
            children: <Widget>[
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: waiting
                      ? AppColors.warning.withOpacity(0.12)
                      : AppColors.primaryTint,
                  borderRadius: AppRadius.controlAll,
                ),
                child: Icon(
                  waiting
                      ? Icons.how_to_reg_outlined
                      : Icons.check_circle_outline_rounded,
                  size: 20,
                  color: waiting ? AppColors.warning : AppColors.success,
                ),
              ),
              const SizedBox(width: Spacing.x3),
              Expanded(
                child: Text(
                  waiting
                      ? l10n.dashboardPendingCta(counts.pending)
                      : l10n.dashboardPendingClear,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (waiting)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CatalogueCounts extends ConsumerWidget {
  const _CatalogueCounts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return DashboardCard<ProductCounts>(
      value: ref.watch(productCountsCardProvider),
      onRetry: () => ref.invalidate(productCountsCardProvider),
      skeletonHeight: 88,
      builder: (BuildContext context, ProductCounts counts) => _StatRow(
        tiles: <_Stat>[
          _Stat(
            label: l10n.statTotalProducts,
            value: counts.total,
            icon: Icons.inventory_2_outlined,
            tone: AppColors.primary,
          ),
          _Stat(
            label: l10n.statActiveProducts,
            value: counts.total - counts.inactive,
            icon: Icons.check_circle_outline_rounded,
            tone: AppColors.success,
          ),
          _Stat(
            label: l10n.statOutOfStock,
            value: counts.outOfStock,
            icon: Icons.production_quantity_limits_outlined,
            tone: counts.outOfStock > 0
                ? AppColors.warning
                : AppColors.textSecondary,
          ),
        ],
        onTap: () => context.go(AppRoutes.ownerProducts),
      ),
    );
  }
}

class _NetworkCounts extends ConsumerWidget {
  const _NetworkCounts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return DashboardCard<DealerCounts>(
      value: ref.watch(dealerCountsCardProvider),
      onRetry: () => ref.invalidate(dealerCountsCardProvider),
      skeletonHeight: 88,
      builder: (BuildContext context, DealerCounts counts) => _StatRow(
        tiles: <_Stat>[
          _Stat(
            label: l10n.statWholesalers,
            value: counts.wholesalers,
            icon: Icons.inventory_2_outlined,
            tone: AppColors.primary,
          ),
          _Stat(
            label: l10n.statRetailers,
            value: counts.retailers,
            icon: Icons.storefront_outlined,
            tone: AppColors.primary,
          ),
          _Stat(
            label: l10n.statSuspended,
            value: counts.suspended,
            icon: Icons.block_outlined,
            tone: counts.suspended > 0
                ? AppColors.danger
                : AppColors.textSecondary,
          ),
        ],
        onTap: () => context.go(AppRoutes.ownerDealers),
      ),
    );
  }
}

class _TopScanned extends ConsumerWidget {
  const _TopScanned();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return DashboardCard<List<ScannedProduct>>(
      value: ref.watch(topScannedCardProvider),
      onRetry: () => ref.invalidate(topScannedCardProvider),
      skeletonHeight: 160,
      builder: (BuildContext context, List<ScannedProduct> rows) {
        if (rows.isEmpty) {
          return _EmptyNote(message: l10n.dashboardTopScannedEmpty);
        }

        // Bars are scaled against the busiest product rather than an absolute
        // count, because the useful comparison is between products, not
        // against a number the owner has no feel for.
        final busiest = rows.first.scanCount;

        return AppCard(
          child: Column(
            children: <Widget>[
              for (var index = 0; index < rows.length; index++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: index == rows.length - 1 ? 0 : Spacing.x4,
                  ),
                  child: _ScanRow(
                    row: rows[index],
                    fraction: busiest == 0
                        ? 0
                        : rows[index].scanCount / busiest,
                    onTap: () => context.push(
                      AppRoutes.ownerProductDetail(rows[index].productId),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ScanRow extends StatelessWidget {
  const _ScanRow({
    required this.row,
    required this.fraction,
    required this.onTap,
  });

  final ScannedProduct row;
  final double fraction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  row.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.x2),
              Text(
                l10n.dashboardScanCount(row.scanCount),
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.x2),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.02, 1),
              minHeight: 5,
              backgroundColor: AppColors.skeletonBase,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentlyAdded extends ConsumerWidget {
  const _RecentlyAdded();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return DashboardCard<List<Product>>(
      value: ref.watch(recentProductsCardProvider),
      onRetry: () => ref.invalidate(recentProductsCardProvider),
      skeletonHeight: 116,
      builder: (BuildContext context, List<Product> products) {
        if (products.isEmpty) {
          return _EmptyNote(message: l10n.productsEmptyBody);
        }

        return SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: Spacing.x3),
            itemBuilder: (_, int index) {
              final product = products[index];
              return SizedBox(
                width: 168,
                child: AppCard(
                  onTap: () =>
                      context.push(AppRoutes.ownerProductDetail(product.id)),
                  padding: const EdgeInsets.all(Spacing.x3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            product.productCode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppFormat.rupees(product.retailPrice),
                            style: context.textTheme.titleSmall?.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ActivityFeed extends ConsumerWidget {
  const _ActivityFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return DashboardCard<List<DealerActivityEntry>>(
      value: ref.watch(dealerActivityCardProvider),
      onRetry: () => ref.invalidate(dealerActivityCardProvider),
      skeletonHeight: 140,
      builder: (BuildContext context, List<DealerActivityEntry> entries) {
        if (entries.isEmpty) {
          return _EmptyNote(message: l10n.dashboardActivityEmpty);
        }

        return AppCard(
          child: Column(
            children: <Widget>[
              for (var index = 0; index < entries.length; index++) ...<Widget>[
                if (index > 0) const Divider(height: Spacing.x5),
                _ActivityRow(entry: entries[index]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.entry});

  final DealerActivityEntry entry;

  /// Maps an audit action onto a sentence and an icon.
  ///
  /// An unrecognised action falls back to the raw string rather than being
  /// hidden: a feed that silently drops entries is worse than one showing an
  /// action nobody has written copy for yet.
  static (String, IconData, Color) _describe(
    AppLocalizations l10n,
    DealerActivityEntry entry,
  ) {
    final firm = entry.firmName.isEmpty ? entry.fullName : entry.firmName;
    return switch (entry.action) {
      'dealer.approved' => (
        l10n.activityApproved(firm),
        Icons.check_circle_outline_rounded,
        AppColors.success,
      ),
      'dealer.rejected' => (
        l10n.activityRejected(firm),
        Icons.cancel_outlined,
        AppColors.danger,
      ),
      'dealer.suspended' => (
        l10n.activitySuspended(firm),
        Icons.block_outlined,
        AppColors.danger,
      ),
      'dealer.reactivated' => (
        l10n.activityReactivated(firm),
        Icons.restart_alt_rounded,
        AppColors.success,
      ),
      'dealer.role_changed' => (
        l10n.activityRoleChanged(firm),
        Icons.swap_horiz_rounded,
        AppColors.primary,
      ),
      _ => (
        '$firm — ${entry.action}',
        Icons.history_rounded,
        AppColors.textSecondary,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (message, icon, tone) = _describe(l10n, entry);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: tone),
        const SizedBox(width: Spacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                RelativeTime.format(l10n, entry.createdAt),
                style: context.textTheme.labelSmall?.copyWith(
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

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: <Widget>[
        Expanded(
          child: _QuickAction(
            label: l10n.actionAddProduct,
            icon: Icons.add_circle_outline_rounded,
            onTap: () => context.push(AppRoutes.ownerProductNew),
          ),
        ),
        const SizedBox(width: Spacing.x3),
        Expanded(
          child: _QuickAction(
            label: l10n.actionViewRequests,
            icon: Icons.how_to_reg_outlined,
            onTap: () => context.push(AppRoutes.ownerDealerRequests),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.x2,
        vertical: Spacing.x4,
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: AppRadius.controlAll,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(height: Spacing.x2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall?.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color tone;
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.tiles, required this.onTap});

  final List<_Stat> tiles;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight is load-bearing, not decoration. These rows are direct
    // children of the dashboard ListView, so they are laid out with an
    // unbounded height; CrossAxisAlignment.stretch passes that straight down
    // and the tiles are asked to be infinitely tall. In debug that is an
    // assertion, and in release it silently consumes the rest of the list --
    // which is what made a shipped build render only the first two of the
    // seven sections. Sizing to the tallest tile first gives stretch a real
    // number to work with, and is what keeps the tiles equal height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var index = 0; index < tiles.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(width: Spacing.x3),
            Expanded(
              child: _StatTile(stat: tiles[index], onTap: onTap),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat, required this.onTap});

  final _Stat stat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Spacing.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(stat.icon, size: 18, color: stat.tone),
          const SizedBox(height: Spacing.x2),
          Text(
            '${stat.value}',
            style: context.textTheme.headlineSmall?.copyWith(
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Text(
        message,
        style: context.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.x3),
    child: Text(
      label.toUpperCase(),
      style: context.textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    ),
  );
}
