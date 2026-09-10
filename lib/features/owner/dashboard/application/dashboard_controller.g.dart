// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productCountsCardHash() => r'd7fad6ba22583cb5da2703f585578eeb2d774c61';

/// The dashboard is deliberately several small providers rather than one.
///
/// A single provider would mean one slow or failing query blanks the whole
/// screen, and the owner opens this screen to answer "is there anything
/// waiting for me" — a question the pending count can answer even when the
/// scan analytics are down. Each card below loads, fails and retries alone.
/// Catalogue totals: how many products, how many need attention.
///
/// Copied from [productCountsCard].
@ProviderFor(productCountsCard)
final productCountsCardProvider =
    AutoDisposeFutureProvider<ProductCounts>.internal(
  productCountsCard,
  name: r'productCountsCardProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productCountsCardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductCountsCardRef = AutoDisposeFutureProviderRef<ProductCounts>;
String _$dealerCountsCardHash() => r'31346d99aceee50a5a7c4766444eee89c88e7508';

/// Dealer headcounts, including the pending queue.
///
/// Copied from [dealerCountsCard].
@ProviderFor(dealerCountsCard)
final dealerCountsCardProvider =
    AutoDisposeFutureProvider<DealerCounts>.internal(
  dealerCountsCard,
  name: r'dealerCountsCardProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dealerCountsCardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DealerCountsCardRef = AutoDisposeFutureProviderRef<DealerCounts>;
String _$topScannedCardHash() => r'55f62eca71580f6ac43f6f5af3c414797e56a983';

/// The five products dealers scanned most in the last [scanWindowDays] days.
///
/// Copied from [topScannedCard].
@ProviderFor(topScannedCard)
final topScannedCardProvider =
    AutoDisposeFutureProvider<List<ScannedProduct>>.internal(
  topScannedCard,
  name: r'topScannedCardProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$topScannedCardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TopScannedCardRef = AutoDisposeFutureProviderRef<List<ScannedProduct>>;
String _$recentProductsCardHash() =>
    r'ffaffd55d01f36d45fb1af50f28c84f4219da365';

/// The most recently added products, for the horizontal strip.
///
/// Copied from [recentProductsCard].
@ProviderFor(recentProductsCard)
final recentProductsCardProvider =
    AutoDisposeFutureProvider<List<Product>>.internal(
  recentProductsCard,
  name: r'recentProductsCardProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentProductsCardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentProductsCardRef = AutoDisposeFutureProviderRef<List<Product>>;
String _$dealerActivityCardHash() =>
    r'56ff21df1dd8b94ca60d1e98ad7ee8aeff629312';

/// The dealer decision feed.
///
/// Copied from [dealerActivityCard].
@ProviderFor(dealerActivityCard)
final dealerActivityCardProvider =
    AutoDisposeFutureProvider<List<DealerActivityEntry>>.internal(
  dealerActivityCard,
  name: r'dealerActivityCardProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dealerActivityCardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DealerActivityCardRef
    = AutoDisposeFutureProviderRef<List<DealerActivityEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
