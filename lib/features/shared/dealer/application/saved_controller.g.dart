// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$savedProductsHash() => r'484b95585977b867e97fbfd759609e948ad47a36';

/// The saved codes resolved against the loaded catalogue.
///
/// A saved code with no matching product is dropped rather than rendered as a
/// blank row: the owner may have deactivated the product since it was saved,
/// and a quotation must not carry a line nobody can supply.
///
/// Copied from [savedProducts].
@ProviderFor(savedProducts)
final savedProductsProvider =
    AutoDisposeProvider<List<CatalogProduct>>.internal(
  savedProducts,
  name: r'savedProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savedProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SavedProductsRef = AutoDisposeProviderRef<List<CatalogProduct>>;
String _$savedControllerHash() => r'90d417fe3d878917089e78cfb47bcb9450f5eecd';

/// The dealer's own shortlist, stored on the device.
///
/// Codes are persisted, not whole products. A saved entry then always reflects
/// the current price and stock rather than whatever they were on the day it
/// was saved, which matters because the list's whole purpose is being turned
/// into a quotation.
///
/// Copied from [SavedController].
@ProviderFor(SavedController)
final savedControllerProvider =
    NotifierProvider<SavedController, List<String>>.internal(
  SavedController.new,
  name: r'savedControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savedControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SavedController = Notifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
