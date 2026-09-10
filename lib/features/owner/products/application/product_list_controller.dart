import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../data/repositories/supabase_product_image_repository.dart';
import '../../../../data/repositories/supabase_product_repository.dart';
import '../../../../domain/enums/product_category.dart';
import '../../../../domain/enums/product_sort.dart';
import '../../../../domain/enums/product_status_filter.dart';
import '../../../../domain/models/product.dart';
import '../../../../domain/models/product_query.dart';

part 'product_list_controller.g.dart';

/// How long the list waits after the last keystroke before querying.
const Duration searchDebounce = Duration(milliseconds: 300);

/// Search, filter and sort state for the product list.
///
/// Typing is debounced here rather than in the widget so the delay is part of
/// the behaviour under test, and so every entry point to the list shares it.
@riverpod
class ProductQueryController extends _$ProductQueryController {
  Timer? _debounce;

  @override
  ProductQuery build() {
    ref.onDispose(() => _debounce?.cancel());
    return const ProductQuery();
  }

  /// Updates the search term after the debounce window closes.
  void search(String term) {
    _debounce?.cancel();
    _debounce = Timer(searchDebounce, () {
      state = state.copyWith(searchTerm: term, page: 0);
    });
  }

  /// Applies a category filter, or clears it when [category] is null.
  void setCategory(ProductCategory? category) {
    state = state.copyWith(category: category, page: 0);
  }

  /// Applies an availability filter.
  void setStatus(ProductStatusFilter status) {
    state = state.copyWith(status: status, page: 0);
  }

  /// Applies an ordering.
  void setSort(ProductSort sort) {
    state = state.copyWith(sort: sort, page: 0);
  }

  /// Clears the search term and every filter.
  void reset() {
    _debounce?.cancel();
    state = const ProductQuery();
  }
}

/// The loaded portion of the product list.
class ProductListState {
  /// Creates a list state.
  const ProductListState({
    required this.products,
    required this.hasMore,
    this.primaryImagePaths = const <String, String>{},
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  /// Every product loaded so far, in query order.
  final List<Product> products;

  /// Product id mapped to the storage path of its primary photograph.
  ///
  /// Absent for a product with no photos, which the card draws as a
  /// placeholder rather than an empty box.
  final Map<String, String> primaryImagePaths;

  /// Whether another page exists on the server.
  final bool hasMore;

  /// Whether the next page is in flight.
  final bool isLoadingMore;

  /// Why the last attempt to extend the list failed, if it did.
  final AppFailure? loadMoreFailure;

  /// Copies with selected fields replaced.
  ProductListState copyWith({
    List<Product>? products,
    bool? hasMore,
    Map<String, String>? primaryImagePaths,
    bool? isLoadingMore,
    AppFailure? loadMoreFailure,
    bool clearFailure = false,
  }) => ProductListState(
    products: products ?? this.products,
    hasMore: hasMore ?? this.hasMore,
    primaryImagePaths: primaryImagePaths ?? this.primaryImagePaths,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailure: clearFailure
        ? null
        : loadMoreFailure ?? this.loadMoreFailure,
  );
}

/// Loads the product list one page at a time.
///
/// The whole table is never fetched: the first page arrives with the screen and
/// further pages are appended as the owner scrolls. Any change to the query
/// rebuilds from page zero rather than appending onto stale results.
@riverpod
class ProductListController extends _$ProductListController {
  ProductQuery _query = const ProductQuery();

  @override
  Future<ProductListState> build() async {
    _query = ref.watch(productQueryControllerProvider);

    final result = await ref
        .read(productRepositoryProvider)
        .fetchPage(_query.copyWith(page: 0));

    final page = result.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw failure,
    );

    return ProductListState(
      products: page.items,
      hasMore: page.hasMore,
      primaryImagePaths: await _thumbnailsFor(page.items),
    );
  }

  /// Resolves the primary photo of each product in [products].
  ///
  /// A failure here returns an empty map rather than propagating: a catalogue
  /// that lists correctly but draws placeholder thumbnails is still usable,
  /// and an unreadable image table must not blank the whole screen.
  Future<Map<String, String>> _thumbnailsFor(List<Product> products) async {
    if (products.isEmpty) {
      return const <String, String>{};
    }
    final result = await ref
        .read(productImageRepositoryProvider)
        .primaryPathsFor(products.map((Product p) => p.id).toList());
    return result.valueOrNull ?? const <String, String>{};
  }

  /// Fetches and appends the next page.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }

    state = AsyncValue<ProductListState>.data(
      current.copyWith(isLoadingMore: true, clearFailure: true),
    );

    final nextPage = _query.page + 1;
    final result = await ref
        .read(productRepositoryProvider)
        .fetchPage(_query.copyWith(page: nextPage));

    final appended = result.valueOrNull;
    final thumbnails = appended == null
        ? const <String, String>{}
        : await _thumbnailsFor(appended.items);

    result.fold(
      onSuccess: (page) {
        _query = _query.copyWith(page: nextPage);
        state = AsyncValue<ProductListState>.data(
          current.copyWith(
            products: <Product>[...current.products, ...page.items],
            hasMore: page.hasMore,
            primaryImagePaths: <String, String>{
              ...current.primaryImagePaths,
              ...thumbnails,
            },
            isLoadingMore: false,
            clearFailure: true,
          ),
        );
      },
      onFailure: (failure) {
        // A failed page must not discard the rows already on screen.
        state = AsyncValue<ProductListState>.data(
          current.copyWith(isLoadingMore: false, loadMoreFailure: failure),
        );
      },
    );
  }

  /// Reloads from the first page.
  Future<void> refresh() async {
    _query = _query.copyWith(page: 0);
    ref.invalidateSelf();
    await future;
  }

  /// Applies a locally known change without a round trip, then refreshes.
  void replaceInPlace(Product product) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncValue<ProductListState>.data(
      current.copyWith(
        products: current.products
            .map((Product p) => p.id == product.id ? product : p)
            .toList(),
      ),
    );
  }

  /// Drops a product from the loaded list after it has been deleted.
  void removeInPlace(String productId) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncValue<ProductListState>.data(
      current.copyWith(
        products: current.products
            .where((Product p) => p.id != productId)
            .toList(),
      ),
    );
  }
}
