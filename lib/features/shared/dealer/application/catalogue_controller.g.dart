// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$visibleCatalogueHash() => r'9334b4988382e050b07bf29b3a7da50b097a2cd2';

/// The catalogue after search, filter and sort have been applied.
///
/// Out-of-stock products are pushed to the end of every ordering. A dealer
/// scrolling a price list is shopping, and something they cannot buy today
/// belongs below everything they can.
///
/// Copied from [visibleCatalogue].
@ProviderFor(visibleCatalogue)
final visibleCatalogueProvider =
    AutoDisposeProvider<List<CatalogProduct>>.internal(
  visibleCatalogue,
  name: r'visibleCatalogueProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$visibleCatalogueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VisibleCatalogueRef = AutoDisposeProviderRef<List<CatalogProduct>>;
String _$connectivityHash() => r'e636d2094055604480706624da324358b1aa5eca';

/// The transports the device currently has, as a stream.
///
/// Copied from [connectivity].
@ProviderFor(connectivity)
final connectivityProvider = StreamProvider<List<ConnectivityResult>>.internal(
  connectivity,
  name: r'connectivityProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$connectivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityRef = StreamProviderRef<List<ConnectivityResult>>;
String _$nowHash() => r'410f2dfb6b16accb799d0c64e676ce06d8cd0200';

/// The current time, injectable so cache expiry is testable.
///
/// Everything that asks "how old is this cache" goes through here rather than
/// calling DateTime.now() directly, which is what lets a test walk the clock
/// past the seven-day boundary without waiting a week.
///
/// Copied from [now].
@ProviderFor(now)
final nowProvider = Provider<DateTime Function()>.internal(
  now,
  name: r'nowProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$nowHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NowRef = ProviderRef<DateTime Function()>;
String _$catalogueControllerHash() =>
    r'25cdb69ea521cf404a7e45db29665d71273d686e';

/// Loads the dealer catalogue, preferring the network and falling back to disk.
///
/// The order of preference is the whole feature. A dealer in a godown on 2G
/// gets the cached catalogue immediately rather than a spinner, and a silent
/// refresh replaces it the moment the network answers. Nothing here blocks on
/// a request that may never complete.
///
/// Copied from [CatalogueController].
@ProviderFor(CatalogueController)
final catalogueControllerProvider =
    AsyncNotifierProvider<CatalogueController, CatalogueState>.internal(
  CatalogueController.new,
  name: r'catalogueControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$catalogueControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CatalogueController = AsyncNotifier<CatalogueState>;
String _$catalogueQueryControllerHash() =>
    r'721db1507cc34b236f3e96b7baa19e7b8abcddb8';

/// Search, category and sort state for the catalogue grid.
///
/// Copied from [CatalogueQueryController].
@ProviderFor(CatalogueQueryController)
final catalogueQueryControllerProvider = AutoDisposeNotifierProvider<
    CatalogueQueryController, CatalogueQuery>.internal(
  CatalogueQueryController.new,
  name: r'catalogueQueryControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$catalogueQueryControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CatalogueQueryController = AutoDisposeNotifier<CatalogueQuery>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
