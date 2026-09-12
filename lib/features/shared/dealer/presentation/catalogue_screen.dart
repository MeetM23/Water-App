import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/brand_wordmark.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../auth/application/session_controller.dart';
import '../../banner/presentation/widgets/banner_carousel_widget.dart';
import '../application/catalogue_controller.dart';
import '../domain/dealer_experience.dart';
import '../domain/price_view_mode.dart';
import 'widgets/catalogue_card.dart';
import 'widgets/catalogue_category_bar.dart';
import 'widgets/catalogue_skeleton.dart';
import 'widgets/offline_banner.dart';

/// The product list shown as the main landing tab for dealers.
class CatalogueScreen extends ConsumerStatefulWidget {
  /// Creates the catalogue tab.
  const CatalogueScreen({
    required this.experience,
    super.key,
  });

  /// Role-specific labels and routes.
  final DealerExperience experience;

  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(catalogueQueryControllerProvider).searchTerm;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(catalogueQueryControllerProvider.notifier).reset();
  }

  Future<void> _refresh() async {
    await ref.read(catalogueControllerProvider.notifier).refresh();
  }

  void _openComplaintShortcut() {
    final session = ref.read(sessionControllerProvider).valueOrNull;
    if (session is SessionSignedIn && session.profile.role == UserRole.owner) {
      context.push(AppRoutes.ownerComplaints);
    } else if (session is SessionSignedIn) {
      context.push(AppRoutes.complaints);
    } else {
      context.push(
        '${AppRoutes.login}?from=${Uri.encodeComponent(AppRoutes.complaints)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalogue = ref.watch(catalogueControllerProvider);
    final query = ref.watch(catalogueQueryControllerProvider);
    final products = ref.watch(visibleCatalogueProvider);
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final viewMode = priceViewModeFromSession(session);

    return Scaffold(
      appBar: AppBar(
        title: const BrandWordmark.compact(),
        actions: <Widget>[
          IconButton(
            onPressed: _openComplaintShortcut,
            icon: const Icon(Icons.home_repair_service_rounded),
            tooltip: l10n.complaintsTitle,
          ),
          const SizedBox(width: Spacing.x2),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.x4,
                  Spacing.x3,
                  Spacing.x4,
                  Spacing.x2,
                ),
                child: AppSearchField(
                  controller: _searchController,
                  hint: l10n.catalogueSearchHint,
                  clearTooltip: l10n.actionClear,
                  onChanged: ref
                      .read(catalogueQueryControllerProvider.notifier)
                      .search,
                ),
              ),
            ),

            // Banner Carousel
            const SliverToBoxAdapter(
              child: BannerCarouselWidget(),
            ),

            // Horizontal Options Bar (All, Domestic, Commercial, Industrial, Accessories, Service)
            SliverToBoxAdapter(
              child: CatalogueCategoryBar(
                onResetFilters: _clearFilters,
              ),
            ),

            // Main Content Area (Loading, Error, Empty, or Products Grid)
            ...catalogue.when(
              loading: () => <Widget>[
                const SliverToBoxAdapter(child: CatalogueSkeleton()),
              ],
              error: (Object error, StackTrace stackTrace) => <Widget>[
                SliverToBoxAdapter(
                  child: AppErrorState(
                    failure: error is AppFailure
                        ? error
                        : UnexpectedFailure(cause: error, stackTrace: stackTrace),
                    onRetry: _refresh,
                  ),
                ),
              ],
              data: (CatalogueState state) {
                final offlineBanner = state.isOffline
                    ? SliverToBoxAdapter(child: OfflineBanner(state: state))
                    : null;

                if (products.isEmpty) {
                  return <Widget>[
                    if (offlineBanner != null) offlineBanner,
                    SliverToBoxAdapter(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.sizeOf(context).height * 0.4,
                        ),
                        child: query.hasActiveFilters
                            ? AppEmptyState(
                                icon: Icons.search_off_rounded,
                                title: l10n.catalogueNoResultsTitle,
                                message: l10n.catalogueNoResultsBody,
                                actionLabel: l10n.productsClearFilters,
                                onAction: _clearFilters,
                              )
                            : AppEmptyState(
                                icon: Icons.inventory_2_outlined,
                                title: l10n.catalogueEmptyTitle,
                                message: l10n.catalogueEmptyBody,
                              ),
                      ),
                    ),
                  ];
                }

                return <Widget>[
                  if (offlineBanner != null) offlineBanner,
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.x4,
                        Spacing.x1,
                        Spacing.x4,
                        Spacing.x2,
                      ),
                      child: Text(
                        l10n.catalogueCountLabel(products.length),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.x4,
                      0,
                      Spacing.x4,
                      Spacing.x8,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: CatalogueGridMetrics.columnsFor(
                          MediaQuery.sizeOf(context).width,
                        ),
                        crossAxisSpacing: Spacing.x3,
                        mainAxisSpacing: Spacing.x3,
                        mainAxisExtent: CatalogueGridMetrics.tileExtent(
                          context,
                          MediaQuery.sizeOf(context).width,
                        ),
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final product = products[index];
                          return CatalogueCard(
                            product: product,
                            viewMode: viewMode,
                            onTap: () => context.push(
                              widget.experience.productRoute(product.productCode),
                            ),
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
