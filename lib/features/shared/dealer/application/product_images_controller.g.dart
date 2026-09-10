// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_images_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productImagesHash() => r'4f08d6ebc15b3d32b505e6516071daf2333160c4';

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

/// Every image for one product, primary first, as storage paths.
///
/// Keyed by id and primary path rather than by the product object itself: a
/// silent catalogue refresh rebuilds every product object, and a family keyed
/// on the whole record would re-run this fetch — and re-download the gallery —
/// because a price moved by a rupee.
///
/// A failed listing is not an error state. The dealer this screen exists for
/// is often standing in a godown with no signal, where the only image that
/// will ever paint is the primary one already in the Hive cache. Showing them
/// an error instead of that one photo would be worse than showing nothing.
///
/// Copied from [productImages].
@ProviderFor(productImages)
const productImagesProvider = ProductImagesFamily();

/// Every image for one product, primary first, as storage paths.
///
/// Keyed by id and primary path rather than by the product object itself: a
/// silent catalogue refresh rebuilds every product object, and a family keyed
/// on the whole record would re-run this fetch — and re-download the gallery —
/// because a price moved by a rupee.
///
/// A failed listing is not an error state. The dealer this screen exists for
/// is often standing in a godown with no signal, where the only image that
/// will ever paint is the primary one already in the Hive cache. Showing them
/// an error instead of that one photo would be worse than showing nothing.
///
/// Copied from [productImages].
class ProductImagesFamily extends Family<AsyncValue<List<String>>> {
  /// Every image for one product, primary first, as storage paths.
  ///
  /// Keyed by id and primary path rather than by the product object itself: a
  /// silent catalogue refresh rebuilds every product object, and a family keyed
  /// on the whole record would re-run this fetch — and re-download the gallery —
  /// because a price moved by a rupee.
  ///
  /// A failed listing is not an error state. The dealer this screen exists for
  /// is often standing in a godown with no signal, where the only image that
  /// will ever paint is the primary one already in the Hive cache. Showing them
  /// an error instead of that one photo would be worse than showing nothing.
  ///
  /// Copied from [productImages].
  const ProductImagesFamily();

  /// Every image for one product, primary first, as storage paths.
  ///
  /// Keyed by id and primary path rather than by the product object itself: a
  /// silent catalogue refresh rebuilds every product object, and a family keyed
  /// on the whole record would re-run this fetch — and re-download the gallery —
  /// because a price moved by a rupee.
  ///
  /// A failed listing is not an error state. The dealer this screen exists for
  /// is often standing in a godown with no signal, where the only image that
  /// will ever paint is the primary one already in the Hive cache. Showing them
  /// an error instead of that one photo would be worse than showing nothing.
  ///
  /// Copied from [productImages].
  ProductImagesProvider call(
    String productId,
    String? primaryImagePath,
  ) {
    return ProductImagesProvider(
      productId,
      primaryImagePath,
    );
  }

  @override
  ProductImagesProvider getProviderOverride(
    covariant ProductImagesProvider provider,
  ) {
    return call(
      provider.productId,
      provider.primaryImagePath,
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
  String? get name => r'productImagesProvider';
}

/// Every image for one product, primary first, as storage paths.
///
/// Keyed by id and primary path rather than by the product object itself: a
/// silent catalogue refresh rebuilds every product object, and a family keyed
/// on the whole record would re-run this fetch — and re-download the gallery —
/// because a price moved by a rupee.
///
/// A failed listing is not an error state. The dealer this screen exists for
/// is often standing in a godown with no signal, where the only image that
/// will ever paint is the primary one already in the Hive cache. Showing them
/// an error instead of that one photo would be worse than showing nothing.
///
/// Copied from [productImages].
class ProductImagesProvider extends AutoDisposeFutureProvider<List<String>> {
  /// Every image for one product, primary first, as storage paths.
  ///
  /// Keyed by id and primary path rather than by the product object itself: a
  /// silent catalogue refresh rebuilds every product object, and a family keyed
  /// on the whole record would re-run this fetch — and re-download the gallery —
  /// because a price moved by a rupee.
  ///
  /// A failed listing is not an error state. The dealer this screen exists for
  /// is often standing in a godown with no signal, where the only image that
  /// will ever paint is the primary one already in the Hive cache. Showing them
  /// an error instead of that one photo would be worse than showing nothing.
  ///
  /// Copied from [productImages].
  ProductImagesProvider(
    String productId,
    String? primaryImagePath,
  ) : this._internal(
          (ref) => productImages(
            ref as ProductImagesRef,
            productId,
            primaryImagePath,
          ),
          from: productImagesProvider,
          name: r'productImagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productImagesHash,
          dependencies: ProductImagesFamily._dependencies,
          allTransitiveDependencies:
              ProductImagesFamily._allTransitiveDependencies,
          productId: productId,
          primaryImagePath: primaryImagePath,
        );

  ProductImagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
    required this.primaryImagePath,
  }) : super.internal();

  final String productId;
  final String? primaryImagePath;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(ProductImagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductImagesProvider._internal(
        (ref) => create(ref as ProductImagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
        primaryImagePath: primaryImagePath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _ProductImagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductImagesProvider &&
        other.productId == productId &&
        other.primaryImagePath == primaryImagePath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);
    hash = _SystemHash.combine(hash, primaryImagePath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductImagesRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `productId` of this provider.
  String get productId;

  /// The parameter `primaryImagePath` of this provider.
  String? get primaryImagePath;
}

class _ProductImagesProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with ProductImagesRef {
  _ProductImagesProviderElement(super.provider);

  @override
  String get productId => (origin as ProductImagesProvider).productId;
  @override
  String? get primaryImagePath =>
      (origin as ProductImagesProvider).primaryImagePath;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
