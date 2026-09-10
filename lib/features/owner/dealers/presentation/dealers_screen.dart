import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/extensions/enum_labels.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/brand_wordmark.dart';
import '../../../../domain/enums/dealer_segment.dart';
import '../../../../domain/models/profile.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../application/approval_queue_controller.dart';
import '../application/dealer_directory_controller.dart';

/// The dealer network.
///
/// The pending queue is not a segment here. Approving somebody is a different
/// job from looking one up, it has its own screen, and putting it behind a
/// banner keeps the count in front of the owner without turning the directory
/// into a to-do list.
class DealersScreen extends ConsumerStatefulWidget {
  /// Creates the directory.
  const DealersScreen({super.key});

  @override
  ConsumerState<DealersScreen> createState() => _DealersScreenState();
}

class _DealersScreenState extends ConsumerState<DealersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = ref.watch(dealerQueryControllerProvider);
    final directory = ref.watch(dealerDirectoryControllerProvider);
    final pending = ref.watch(pendingDealerCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const BrandWordmark.compact(),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.push(AppRoutes.ownerDealerRequests),
            tooltip: l10n.requestsTitle,
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              backgroundColor: AppColors.warning,
              child: const Icon(Icons.how_to_reg_outlined),
            ),
          ),
          const SizedBox(width: Spacing.x2),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.x4,
              Spacing.x3,
              Spacing.x4,
              Spacing.x2,
            ),
            child: AppSearchField(
              controller: _searchController,
              hint: l10n.directorySearchHint,
              clearTooltip: l10n.actionClear,
              onChanged: ref
                  .read(dealerQueryControllerProvider.notifier)
                  .search,
            ),
          ),
          _SegmentBar(
            selected: query.segment,
            onSelected: ref
                .read(dealerQueryControllerProvider.notifier)
                .setSegment,
          ),
          if (pending > 0)
            _PendingBanner(
              count: pending,
              onTap: () => context.push(AppRoutes.ownerDealerRequests),
            ),
          Expanded(
            child: directory.when(
              loading: () => const _DirectorySkeleton(),
              error: (Object error, StackTrace stackTrace) => AppErrorState(
                failure: error is AppFailure
                    ? error
                    : UnexpectedFailure(cause: error, stackTrace: stackTrace),
                onRetry: () => ref
                    .read(dealerDirectoryControllerProvider.notifier)
                    .refresh(),
              ),
              data: (List<Profile> dealers) => RefreshIndicator(
                onRefresh: () => ref
                    .read(dealerDirectoryControllerProvider.notifier)
                    .refresh(),
                child: dealers.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: <Widget>[
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.sizeOf(context).height * 0.5,
                            ),
                            child: query.isSearching
                                ? AppEmptyState(
                                    icon: Icons.search_off_rounded,
                                    title: l10n.directoryNoResultsTitle,
                                    message: l10n.directoryNoResultsBody,
                                    actionLabel: l10n.actionClear,
                                    onAction: () {
                                      _searchController.clear();
                                      ref
                                          .read(
                                            dealerQueryControllerProvider
                                                .notifier,
                                          )
                                          .clearSearch();
                                    },
                                  )
                                : AppEmptyState(
                                    icon: Icons.people_outline_rounded,
                                    title: l10n.directoryEmptyTitle,
                                    message: l10n.directoryEmptyBody,
                                  ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Spacing.x4),
                        itemCount: dealers.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: Spacing.x3),
                        itemBuilder: (_, int index) => _DirectoryRow(
                          profile: dealers[index],
                          onTap: () => context.push(
                            AppRoutes.ownerDealerDetail(dealers[index].id),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({required this.selected, required this.onSelected});

  final DealerSegment selected;
  final ValueChanged<DealerSegment> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // A scrolling row of chips rather than a SegmentedButton: four Gujarati
    // labels do not fit across a 320dp screen, and a segmented control has no
    // way to overflow gracefully.
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.x4),
        children: <Widget>[
          for (final segment in DealerSegment.values)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.x2),
              child: ChoiceChip(
                label: Text(_label(l10n, segment)),
                selected: selected == segment,
                showCheckmark: false,
                onSelected: (_) => onSelected(segment),
              ),
            ),
        ],
      ),
    );
  }

  static String _label(AppLocalizations l10n, DealerSegment segment) =>
      switch (segment) {
        DealerSegment.all => l10n.directorySegmentAll,
        DealerSegment.wholesalers => l10n.directorySegmentWholesalers,
        DealerSegment.retailers => l10n.directorySegmentRetailers,
        DealerSegment.suspended => l10n.directorySegmentSuspended,
      };
}

class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.x4, Spacing.x2, Spacing.x4, 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.controlAll,
        child: Container(
          padding: const EdgeInsets.all(Spacing.x3),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.10),
            borderRadius: AppRadius.controlAll,
            border: Border.all(
              color: AppColors.warning.withOpacity(0.35),
            ),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.how_to_reg_outlined,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: Spacing.x2),
              Expanded(
                child: Text(
                  context.l10n.directoryPendingBanner(count),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.warning,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectoryRow extends StatelessWidget {
  const _DirectoryRow({required this.profile, required this.onTap});

  final Profile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Spacing.x4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  profile.firmName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.fullName} · ${profile.city}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: Spacing.x2),
                Wrap(
                  spacing: Spacing.x2,
                  runSpacing: Spacing.x1,
                  children: <Widget>[
                    AppBadge(
                      label: profile.role.label(l10n),
                      tone: AppBadgeTone.info,
                    ),
                    AppBadge(
                      label: profile.status.label(l10n),
                      tone: profile.status.tone,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.x2),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _DirectorySkeleton extends StatelessWidget {
  const _DirectorySkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(Spacing.x4),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
        itemBuilder: (_, __) => const AppSkeleton(height: 96),
      ),
    );
  }
}
