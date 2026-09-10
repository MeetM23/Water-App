// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_lookup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productByCodeHash() => r'5c73a53d3d0ef5f73983166a3a9e3879ea55a139';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// One product resolved by code, for the detail screen.
///
/// Offline-first for the same reason as the scanner: a dealer who scanned a
/// label with no signal must still see the product they scanned.
///
/// Copied from [productByCode].
@ProviderFor(productByCode)
const productByCodeProvider = ProductByCodeFamily();

/// One product resolved by code, for the detail screen.
///
/// Offline-first for the same reason as the scanner: a dealer who scanned a
/// label with no signal must still see the product they scanned.
///
/// Copied from [productByCode].
class ProductByCodeFamily extends Family<AsyncValue<CatalogProduct?>> {
  /// One product resolved by code, for the detail screen.
  ///
  /// Offline-first for the same reason as the scanner: a dealer who scanned a
  /// label with no signal must still see the product they scanned.
  ///
  /// Copied from [productByCode].
  const ProductByCodeFamily();

  /// One product resolved by code, for the detail screen.
  ///
  /// Offline-first for the same reason as the scanner: a dealer who scanned a
  /// label with no signal must still see the product they scanned.
  ///
  /// Copied from [productByCode].
  ProductByCodeProvider call(
    String productCode,
  ) {
    return ProductByCodeProvider(
      productCode,
    );
  }

  @override
  ProductByCodeProvider getProviderOverride(
    covariant ProductByCodeProvider provider,
  ) {
    return call(
      provider.productCode,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productByCodeProvider';
}

/// One product resolved by code, for the detail screen.
///
/// Offline-first for the same reason as the scanner: a dealer who scanned a
/// label with no signal must still see the product they scanned.
///
/// Copied from [productByCode].
class ProductByCodeProvider extends AutoDisposeFutureProvider<CatalogProduct?> {
  /// One product resolved by code, for the detail screen.
  ///
  /// Offline-first for the same reason as the scanner: a dealer who scanned a
  /// label with no signal must still see the product they scanned.
  ///
  /// Copied from [productByCode].
  ProductByCodeProvider(
    String productCode,
  ) : this._internal(
          (ref) => productByCode(
            ref as ProductByCodeRef,
            productCode,
          ),
          from: productByCodeProvider,
          name: r'productByCodeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productByCodeHash,
          dependencies: ProductByCodeFamily._dependencies,
          allTransitiveDependencies:
              ProductByCodeFamily._allTransitiveDependencies,
          productCode: productCode,
        );

  ProductByCodeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productCode,
  }) : super.internal();

  final String productCode;

  @override
  Override overrideWith(
    FutureOr<CatalogProduct?> Function(ProductByCodeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductByCodeProvider._internal(
        (ref) => create(ref as ProductByCodeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productCode: productCode,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CatalogProduct?> createElement() {
    return _ProductByCodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductByCodeProvider && other.productCode == productCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductByCodeRef on AutoDisposeFutureProviderRef<CatalogProduct?> {
  /// The parameter `productCode` of this provider.
  String get productCode;
}

class _ProductByCodeProviderElement
    extends AutoDisposeFutureProviderElement<CatalogProduct?>
    with ProductByCodeRef {
  _ProductByCodeProviderElement(super.provider);

  @override
  String get productCode => (origin as ProductByCodeProvider).productCode;
}

String _$productLookupControllerHash() =>
    r'a351be66b12d5615ce35dbe89ced709e5c86c834';

/// Resolves a product code or unit serial number, offline first.
///
/// Copied from [ProductLookupController].
@ProviderFor(ProductLookupController)
final productLookupControllerProvider =
    AutoDisposeNotifierProvider<ProductLookupController, void>.internal(
  ProductLookupController.new,
  name: r'productLookupControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productLookupControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductLookupController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
