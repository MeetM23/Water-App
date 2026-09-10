import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../data/cache/hive_catalogue_cache.dart';
import '../../../../data/repositories/supabase_catalog_repository.dart';
import '../../../../domain/enums/product_category.dart';
import '../../../../domain/models/catalog_product.dart';
import '../../../../domain/models/catalogue_snapshot.dart';
import 'session_guard.dart';

part 'catalogue_controller.g.dart';

/// Where the catalogue on screen came from.
enum CatalogueSource {
  /// Fetched from the server during this load.
  live,

  /// Read from the Hive cache because the server could not be reached.
  cache,
}

/// How the catalogue list is ordered.
enum CatalogueSort {
  /// Alphabetical by product name.
  name,

  /// Cheapest first.
  priceAscending,

  /// Most expensive first.
  priceDescending,
}

/// The catalogue, plus everything the UI needs to explain where it came from.
class CatalogueState {
  /// Creates a catalogue state.
  const CatalogueState({
    required this.products,
    required this.source,
    required this.fetchedAt,
    this.isExpired = false,
    this.isRefreshing = false,
  });

  /// Every product the dealer is entitled to see.
  final List<CatalogProduct> products;

  /// Whether this came off the network or off the disk.
  final CatalogueSource source;

  /// When this data was read from the server, cached or otherwise.
  final DateTime fetchedAt;

  /// Whether a cached catalogue is older than [catalogueCacheLifetime].
  ///
  /// An expired cache is still handed to the UI rather than withheld: the
  /// screen shows the products behind a prominent warning, because a dealer
  /// who can see stale prices and knows they are stale is better off than one
  /// staring at an error.
  final bool isExpired;

  /// Whether a silent background refresh is in flight.
  final bool isRefreshing;

  /// Whether the banner explaining the offline state should be shown.
  bool get isOffline => source == CatalogueSource.cache;

  /// Copies with selected fields replaced.
  CatalogueState copyWith({
    List<CatalogProduct>? products,
    CatalogueSource? source,
    DateTime? fetchedAt,
    bool? isExpired,
    bool? isRefreshing,
  }) => CatalogueState(
    products: products ?? this.products,
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    isExpired: isExpired ?? this.isExpired,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );
}

/// Loads the dealer catalogue, preferring the network and falling back to disk.
///
/// The order of preference is the whole feature. A dealer in a godown on 2G
/// gets the cached catalogue immediately rather than a spinner, and a silent
/// refresh replaces it the moment the network answers. Nothing here blocks on
/// a request that may never complete.
@Riverpod(keepAlive: true)
class CatalogueController extends _$CatalogueController {
  @override
  Future<CatalogueState> build() async {
    // Watching connectivity means a dealer walking back into signal gets a
    // fresh catalogue without touching anything.
    ref.listen<AsyncValue<List<ConnectivityResult>>>(
      connectivityProvider,
      (
        AsyncValue<List<ConnectivityResult>>? previous,
        AsyncValue<List<ConnectivityResult>> next,
      ) {
        if (_hasConnection(next.valueOrNull) &&
            !_hasConnection(previous?.valueOrNull)) {
          unawaited(refreshSilently());
        }
      },
    );

    return _load();
  }

  /// Whether any transport in [results] can actually carry a request.
  ///
  /// connectivity_plus reports a list because a phone can be on wifi and
  /// mobile data at once, and it reports `none` as a single-element list
  /// rather than an empty one.
  static bool _hasConnection(List<ConnectivityResult>? results) =>
      results != null &&
      results.any((ConnectivityResult r) => r != ConnectivityResult.none);

  Future<CatalogueState> _load() async {
    final cache = ref.read(catalogueCacheProvider);
    final result = await ref.read(catalogRepositoryProvider).fetchCatalogue();

    final failure = result.failureOrNull;
    if (failure == null) {
      final products = result.valueOrNull!;
      final previous = cache.readCatalogue();

      // A catalogue that just went from "products" to "none" is the signature
      // of a suspension, not of the owner deleting their entire stock.
      // catalog_view carries `where is_approved()` inside it, so a suspended
      // dealer is handed zero rows rather than an error — this is the only
      // place that silence is visible. The guard re-reads the profile and the
      // router acts only if the status really changed, so the cost of being
      // wrong is one query.
      if (products.isEmpty && (previous?.products.isNotEmpty ?? false)) {
        AppLog.warn(
          'Catalogue emptied while a cached copy has products; '
          'verifying the account is still approved',
        );
        ref.read(sessionGuardProvider).verifyStillApproved();
      }

      final snapshot = CatalogueSnapshot(
        products: products,
        fetchedAt: ref.read(nowProvider)(),
      );
      // Written before returning so a crash on the very next frame still
      // leaves a usable offline catalogue behind.
      await cache.writeCatalogue(snapshot);

      return CatalogueState(
        products: products,
        source: CatalogueSource.live,
        fetchedAt: snapshot.fetchedAt,
      );
    }

    // A revoked session is not an offline condition. Showing a cached
    // catalogue to a dealer the owner has just suspended would be exactly the
    // wrong response, so it propagates and the guard routes them out.
    if (failure is SessionRevokedFailure) {
      throw failure;
    }

    final cached = cache.readCatalogue();
    if (cached == null) {
      throw failure;
    }

    final now = ref.read(nowProvider)();
    AppLog.warn('Catalogue served from cache after a failed fetch');

    return CatalogueState(
      products: cached.products,
      source: CatalogueSource.cache,
      fetchedAt: cached.fetchedAt,
      isExpired: cached.isExpiredAt(now),
    );
  }

  /// Reloads from the server, showing the loading state.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Reloads from the server without disturbing what is on screen.
  ///
  /// Used when connectivity returns and after a pull-to-refresh that already
  /// has data: replacing a visible list with a skeleton because the network
  /// came back would be a worse experience than the offline banner.
  Future<void> refreshSilently() async {
    final current = state.valueOrNull;
    if (current == null || current.isRefreshing) {
      return;
    }

    state = AsyncValue<CatalogueState>.data(
      current.copyWith(isRefreshing: true),
    );

    final result = await ref.read(catalogRepositoryProvider).fetchCatalogue();
    final failure = result.failureOrNull;

    if (failure != null) {
      if (failure is SessionRevokedFailure) {
        ref.read(sessionGuardProvider).reportRevoked();
      }
      // A failed silent refresh leaves the existing data alone. It failed
      // silently on purpose.
      state = AsyncValue<CatalogueState>.data(
        current.copyWith(isRefreshing: false),
      );
      return;
    }

    final products = result.valueOrNull!;
    final snapshot = CatalogueSnapshot(
      products: products,
      fetchedAt: ref.read(nowProvider)(),
    );
    await ref.read(catalogueCacheProvider).writeCatalogue(snapshot);

    state = AsyncValue<CatalogueState>.data(
      CatalogueState(
        products: products,
        source: CatalogueSource.live,
        fetchedAt: snapshot.fetchedAt,
      ),
    );
  }

  /// Finds a product in the loaded catalogue by its code.
  ///
  /// This is what makes the scanner work offline: the cached catalogue is
  /// already in memory, so a scan resolves with no network at all.
  CatalogProduct? findInLoaded(String productCode) {
    final loaded = state.valueOrNull?.products;
    if (loaded == null) {
      return null;
    }
    for (final product in loaded) {
      if (product.productCode == productCode) {
        return product;
      }
    }
    return null;
  }
}

/// Search, category and sort state for the catalogue grid.
@riverpod
class CatalogueQueryController extends _$CatalogueQueryController {
  Timer? _debounce;

  @override
  CatalogueQuery build() {
    ref.onDispose(() => _debounce?.cancel());
    return const CatalogueQuery();
  }

  /// Updates the search term once typing pauses.
  void search(String term) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      state = state.copyWith(searchTerm: term);
    });
  }

  /// Applies a category filter, or clears it when [category] is null.
  void setCategory(ProductCategory? category) =>
      state = CatalogueQuery(
        searchTerm: state.searchTerm,
        category: category,
        sort: state.sort,
      );

  /// Applies an ordering.
  void setSort(CatalogueSort sort) => state = state.copyWith(sort: sort);

  /// Clears the search term and the category filter.
  void reset() {
    _debounce?.cancel();
    state = CatalogueQuery(sort: state.sort);
  }
}

/// What the dealer has narrowed the catalogue to.
class CatalogueQuery {
  /// Creates a query.
  const CatalogueQuery({
    this.searchTerm = '',
    this.category,
    this.sort = CatalogueSort.name,
  });

  /// Free-text search over name, model number and product code.
  final String searchTerm;

  /// Category filter, or null for all.
  final ProductCategory? category;

  /// Ordering.
  final CatalogueSort sort;

  /// Whether anything narrows the full catalogue.
  bool get hasActiveFilters => searchTerm.trim().isNotEmpty || category != null;

  /// Copies with selected fields replaced.
  ///
  /// Note there is no way to clear [category] through this: use the
  /// constructor. That is deliberate — a copyWith that cannot express null is
  /// less surprising than one where passing null silently keeps the old value.
  CatalogueQuery copyWith({
    String? searchTerm,
    ProductCategory? category,
    CatalogueSort? sort,
  }) => CatalogueQuery(
    searchTerm: searchTerm ?? this.searchTerm,
    category: category ?? this.category,
    sort: sort ?? this.sort,
  );
}

/// The catalogue after search, filter and sort have been applied.
///
/// Out-of-stock products are pushed to the end of every ordering. A dealer
/// scrolling a price list is shopping, and something they cannot buy today
/// belongs below everything they can.
@riverpod
List<CatalogProduct> visibleCatalogue(Ref<List<CatalogProduct>> ref) {
  final state = ref.watch(catalogueControllerProvider).valueOrNull;
  if (state == null) {
    return const <CatalogProduct>[];
  }

  final query = ref.watch(catalogueQueryControllerProvider);
  final term = query.searchTerm.trim().toLowerCase();

  final filtered = state.products.where((CatalogProduct product) {
    if (query.category != null && product.category != query.category) {
      return false;
    }
    if (term.isEmpty) {
      return true;
    }
    return product.name.toLowerCase().contains(term) ||
        (product.modelNumber?.toLowerCase().contains(term) ?? false) ||
        product.productCode.toLowerCase().contains(term);
  }).toList();

  filtered.sort((CatalogProduct a, CatalogProduct b) {
    if (a.inStock != b.inStock) {
      return a.inStock ? -1 : 1;
    }
    return switch (query.sort) {
      CatalogueSort.name =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      CatalogueSort.priceAscending => a.price.compareTo(b.price),
      CatalogueSort.priceDescending => b.price.compareTo(a.price),
    };
  });

  return filtered;
}

/// The transports the device currently has, as a stream.
@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivity(
  Ref<AsyncValue<List<ConnectivityResult>>> ref,
) => Connectivity().onConnectivityChanged;

/// The current time, injectable so cache expiry is testable.
///
/// Everything that asks "how old is this cache" goes through here rather than
/// calling DateTime.now() directly, which is what lets a test walk the clock
/// past the seven-day boundary without waiting a week.
@Riverpod(keepAlive: true)
DateTime Function() now(Ref<DateTime Function()> ref) => DateTime.now;
