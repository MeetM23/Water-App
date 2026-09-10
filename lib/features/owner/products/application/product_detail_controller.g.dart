// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$signedImageUrlHash() => r'36a5220d8169023d5bf9ae0dd354001541482e4d';

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

/// Resolves a signed URL for one stored image path.
///
/// The bucket is private, so nothing renders from a bare path. Kept as its own
/// provider so each tile fetches independently and a slow signature does not
/// hold up the rest of the gallery.
///
/// Copied from [signedImageUrl].
@ProviderFor(signedImageUrl)
const signedImageUrlProvider = SignedImageUrlFamily();

/// Resolves a signed URL for one stored image path.
///
/// The bucket is private, so nothing renders from a bare path. Kept as its own
/// provider so each tile fetches independently and a slow signature does not
/// hold up the rest of the gallery.
///
/// Copied from [signedImageUrl].
class SignedImageUrlFamily extends Family<AsyncValue<String?>> {
  /// Resolves a signed URL for one stored image path.
  ///
  /// The bucket is private, so nothing renders from a bare path. Kept as its own
  /// provider so each tile fetches independently and a slow signature does not
  /// hold up the rest of the gallery.
  ///
  /// Copied from [signedImageUrl].
  const SignedImageUrlFamily();

  /// Resolves a signed URL for one stored image path.
  ///
  /// The bucket is private, so nothing renders from a bare path. Kept as its own
  /// provider so each tile fetches independently and a slow signature does not
  /// hold up the rest of the gallery.
  ///
  /// Copied from [signedImageUrl].
  SignedImageUrlProvider call(
    String path,
  ) {
    return SignedImageUrlProvider(
      path,
    );
  }

  @override
  SignedImageUrlProvider getProviderOverride(
    covariant SignedImageUrlProvider provider,
  ) {
    return call(
      provider.path,
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
  String? get name => r'signedImageUrlProvider';
}

/// Resolves a signed URL for one stored image path.
///
/// The bucket is private, so nothing renders from a bare path. Kept as its own
/// provider so each tile fetches independently and a slow signature does not
/// hold up the rest of the gallery.
///
/// Copied from [signedImageUrl].
class SignedImageUrlProvider extends AutoDisposeFutureProvider<String?> {
  /// Resolves a signed URL for one stored image path.
  ///
  /// The bucket is private, so nothing renders from a bare path. Kept as its own
  /// provider so each tile fetches independently and a slow signature does not
  /// hold up the rest of the gallery.
  ///
  /// Copied from [signedImageUrl].
  SignedImageUrlProvider(
    String path,
  ) : this._internal(
          (ref) => signedImageUrl(
            ref as SignedImageUrlRef,
            path,
          ),
          from: signedImageUrlProvider,
          name: r'signedImageUrlProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$signedImageUrlHash,
          dependencies: SignedImageUrlFamily._dependencies,
          allTransitiveDependencies:
              SignedImageUrlFamily._allTransitiveDependencies,
          path: path,
        );

  SignedImageUrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
  }) : super.internal();

  final String path;

  @override
  Override overrideWith(
    FutureOr<String?> Function(SignedImageUrlRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SignedImageUrlProvider._internal(
        (ref) => create(ref as SignedImageUrlRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        path: path,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _SignedImageUrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SignedImageUrlProvider && other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SignedImageUrlRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `path` of this provider.
  String get path;
}

class _SignedImageUrlProviderElement
    extends AutoDisposeFutureProviderElement<String?> with SignedImageUrlRef {
  _SignedImageUrlProviderElement(super.provider);

  @override
  String get path => (origin as SignedImageUrlProvider).path;
}

String _$productDetailControllerHash() =>
    r'e867de0256fd38d067ecef029f1086643971720e';

abstract class _$ProductDetailController
    extends BuildlessAutoDisposeAsyncNotifier<ProductDetail> {
  late final String productId;

  FutureOr<ProductDetail> build(
    String productId,
  );
}

/// Loads one product, its images and its scan count together.
///
/// Copied from [ProductDetailController].
@ProviderFor(ProductDetailController)
const productDetailControllerProvider = ProductDetailControllerFamily();

/// Loads one product, its images and its scan count together.
///
/// Copied from [ProductDetailController].
class ProductDetailControllerFamily extends Family<AsyncValue<ProductDetail>> {
  /// Loads one product, its images and its scan count together.
  ///
  /// Copied from [ProductDetailController].
  const ProductDetailControllerFamily();

  /// Loads one product, its images and its scan count together.
  ///
  /// Copied from [ProductDetailController].
  ProductDetailControllerProvider call(
    String productId,
  ) {
    return ProductDetailControllerProvider(
      productId,
    );
  }

  @override
  ProductDetailControllerProvider getProviderOverride(
    covariant ProductDetailControllerProvider provider,
  ) {
    return call(
      provider.productId,
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
  String? get name => r'productDetailControllerProvider';
}

/// Loads one product, its images and its scan count together.
///
/// Copied from [ProductDetailController].
class ProductDetailControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ProductDetailController,
        ProductDetail> {
  /// Loads one product, its images and its scan count together.
  ///
  /// Copied from [ProductDetailController].
  ProductDetailControllerProvider(
    String productId,
  ) : this._internal(
          () => ProductDetailController()..productId = productId,
          from: productDetailControllerProvider,
          name: r'productDetailControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productDetailControllerHash,
          dependencies: ProductDetailControllerFamily._dependencies,
          allTransitiveDependencies:
              ProductDetailControllerFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  FutureOr<ProductDetail> runNotifierBuild(
    covariant ProductDetailController notifier,
  ) {
    return notifier.build(
      productId,
    );
  }

  @override
  Override overrideWith(ProductDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductDetailControllerProvider._internal(
        () => create()..productId = productId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProductDetailController,
      ProductDetail> createElement() {
    return _ProductDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailControllerProvider &&
        other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ProductDetail> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductDetailControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProductDetailController,
        ProductDetail> with ProductDetailControllerRef {
  _ProductDetailControllerProviderElement(super.provider);

  @override
  String get productId => (origin as ProductDetailControllerProvider).productId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
