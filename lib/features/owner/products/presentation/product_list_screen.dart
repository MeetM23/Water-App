import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_presentation.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/brand_wordmark.dart';
import '../../../../domain/models/product.dart';
import '../application/product_list_controller.dart';
import 'widgets/product_card.dart';
import 'widgets/product_filter_sheet.dart';
import 'widgets/product_list_skeleton.dart';
import 'widgets/product_quick_actions.dart';

/// The owner catalogue.
class ProductListScreen extends ConsumerStatefulWidget {
  /// Creates the product list.
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Requests the next page once the list is within one screen of the end.
  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600) {
      unawaited(ref.read(productListControllerProvider.notifier).loadMore());
    }
  }

  Future<void> _openQuickActions(Product product) =>
      ProductQuickActions.show(context, product: product);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listState = ref.watch(productListControllerProvider);
    final query = ref.watch(productQueryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const BrandWordmark.compact(),
        actions: <Widget>[
          IconButton(
            onPressed: () => ProductFilterSheet.show(context),
            icon: Badge(
              isLabelVisible: query.hasActiveFilters,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.tune_rounded),
            ),
            tooltip: l10n.filterTitle,
          ),
          const SizedBox(width: Spacing.x2),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: 'print_labels_fab',
            onPressed: () => context.push(AppRoutes.ownerPrintLabels),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.primary,
            icon: const Icon(Icons.print_rounded),
            label: Text(l10n.actionPrintLabels),
          ),
          const SizedBox(height: Spacing.x3),
          FloatingActionButton.extended(
            heroTag: 'add_product_fab',
            onPressed: () => context.push(AppRoutes.ownerProductNew),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.actionAddProduct),
          ),
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
              hint: l10n.searchProductsHint,
              clearTooltip: l10n.actionClear,
              onChanged: ref
                  .read(productQueryControllerProvider.notifier)
                  .search,
            ),
          ),
          Expanded(
            child: listState.when(
              loading: () => const ProductListSkeleton(),
              error: (Object error, StackTrace stackTrace) => AppErrorState(
                failure: error is AppFailure
                    ? error
                    : UnexpectedFailure(cause: error, stackTrace: stackTrace),
                onRetry: () =>
                    ref.read(productListControllerProvider.notifier).refresh(),
              ),
              data: (ProductListState state) => _ProductList(
                state: state,
                scrollController: _scrollController,
                hasFilters: query.hasActiveFilters,
                onRefresh: () =>
                    ref.read(productListControllerProvider.notifier).refresh(),
                onClearFilters: () {
                  _searchController.clear();
                  ref.read(productQueryControllerProvider.notifier).reset();
                },
                onOpen: (Product product) =>
                    context.push(AppRoutes.ownerProductDetail(product.id)),
                onQuickActions: _openQuickActions,
                onAdd: () => context.push(AppRoutes.ownerProductNew),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.state,
    required this.scrollController,
    required this.hasFilters,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onOpen,
    required this.onQuickActions,
    required this.onAdd,
  });

  final ProductListState state;
  final ScrollController scrollController;
  final bool hasFilters;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final void Function(Product product) onOpen;
  final void Function(Product product) onQuickActions;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (state.products.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height * 0.6,
              ),
              child: hasFilters
                  ? AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: l10n.productsNoResultsTitle,
                      message: l10n.productsNoResultsBody,
                      actionLabel: l10n.productsClearFilters,
                      onAction: onClearFilters,
                    )
                  : AppEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: l10n.productsEmptyTitle,
                      message: l10n.productsEmptyBody,
                      actionLabel: l10n.actionAddProduct,
                      onAction: onAdd,
                    ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          Spacing.x4,
          Spacing.x2,
          Spacing.x4,
          Spacing.x10 * 2,
        ),
        itemCount: state.products.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
        itemBuilder: (BuildContext context, int index) {
          if (index >= state.products.length) {
            return _ListFooter(state: state);
          }
          final product = state.products[index];
          return ProductCard(
            product: product,
            primaryImagePath: state.primaryImagePaths[product.id],
            onTap: () => onOpen(product),
            onLongPress: () => onQuickActions(product),
          );
        },
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final ProductListState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadMoreFailure != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.x5),
        child: Center(
          child: Text(
            state.loadMoreFailure!.title(context.l10n),
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.x6),
      child: Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
