// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productQueryControllerHash() =>
    r'9c478438ad73420ebde8fe2b8fa51ee596f50eac';

/// Search, filter and sort state for the product list.
///
/// Typing is debounced here rather than in the widget so the delay is part of
/// the behaviour under test, and so every entry point to the list shares it.
///
/// Copied from [ProductQueryController].
@ProviderFor(ProductQueryController)
final productQueryControllerProvider =
    AutoDisposeNotifierProvider<ProductQueryController, ProductQuery>.internal(
  ProductQueryController.new,
  name: r'productQueryControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productQueryControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductQueryController = AutoDisposeNotifier<ProductQuery>;
String _$productListControllerHash() =>
    r'efe5419e006f1dfa4f86e3007830197264e852f2';

/// Loads the product list one page at a time.
///
/// The whole table is never fetched: the first page arrives with the screen and
/// further pages are appended as the owner scrolls. Any change to the query
/// rebuilds from page zero rather than appending onto stale results.
///
/// Copied from [ProductListController].
@ProviderFor(ProductListController)
final productListControllerProvider = AutoDisposeAsyncNotifierProvider<
    ProductListController, ProductListState>.internal(
  ProductListController.new,
  name: r'productListControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productListControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductListController = AutoDisposeAsyncNotifier<ProductListState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
