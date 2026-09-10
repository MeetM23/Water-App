// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productFormControllerHash() =>
    r'75e7ea4cf79984aa0c8beacaebd5e69f0e9bd91a';

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

abstract class _$ProductFormController
    extends BuildlessAutoDisposeAsyncNotifier<ProductDraft> {
  late final String? productId;

  FutureOr<ProductDraft> build(
    String? productId,
  );
}

/// Owns the product form: its draft, its uploads, and its save.
///
/// Uploads land under a temporary storage prefix keyed by [_sessionId] and are
/// moved into place only on a successful save, so abandoning the form leaves
/// nothing behind in the bucket.
///
/// Copied from [ProductFormController].
@ProviderFor(ProductFormController)
const productFormControllerProvider = ProductFormControllerFamily();

/// Owns the product form: its draft, its uploads, and its save.
///
/// Uploads land under a temporary storage prefix keyed by [_sessionId] and are
/// moved into place only on a successful save, so abandoning the form leaves
/// nothing behind in the bucket.
///
/// Copied from [ProductFormController].
class ProductFormControllerFamily extends Family<AsyncValue<ProductDraft>> {
  /// Owns the product form: its draft, its uploads, and its save.
  ///
  /// Uploads land under a temporary storage prefix keyed by [_sessionId] and are
  /// moved into place only on a successful save, so abandoning the form leaves
  /// nothing behind in the bucket.
  ///
  /// Copied from [ProductFormController].
  const ProductFormControllerFamily();

  /// Owns the product form: its draft, its uploads, and its save.
  ///
  /// Uploads land under a temporary storage prefix keyed by [_sessionId] and are
  /// moved into place only on a successful save, so abandoning the form leaves
  /// nothing behind in the bucket.
  ///
  /// Copied from [ProductFormController].
  ProductFormControllerProvider call(
    String? productId,
  ) {
    return ProductFormControllerProvider(
      productId,
    );
  }

  @override
  ProductFormControllerProvider getProviderOverride(
    covariant ProductFormControllerProvider provider,
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
  String? get name => r'productFormControllerProvider';
}

/// Owns the product form: its draft, its uploads, and its save.
///
/// Uploads land under a temporary storage prefix keyed by [_sessionId] and are
/// moved into place only on a successful save, so abandoning the form leaves
/// nothing behind in the bucket.
///
/// Copied from [ProductFormController].
class ProductFormControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ProductFormController,
        ProductDraft> {
  /// Owns the product form: its draft, its uploads, and its save.
  ///
  /// Uploads land under a temporary storage prefix keyed by [_sessionId] and are
  /// moved into place only on a successful save, so abandoning the form leaves
  /// nothing behind in the bucket.
  ///
  /// Copied from [ProductFormController].
  ProductFormControllerProvider(
    String? productId,
  ) : this._internal(
          () => ProductFormController()..productId = productId,
          from: productFormControllerProvider,
          name: r'productFormControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productFormControllerHash,
          dependencies: ProductFormControllerFamily._dependencies,
          allTransitiveDependencies:
              ProductFormControllerFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductFormControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String? productId;

  @override
  FutureOr<ProductDraft> runNotifierBuild(
    covariant ProductFormController notifier,
  ) {
    return notifier.build(
      productId,
    );
  }

  @override
  Override overrideWith(ProductFormController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductFormControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ProductFormController, ProductDraft>
      createElement() {
    return _ProductFormControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductFormControllerProvider &&
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
mixin ProductFormControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ProductDraft> {
  /// The parameter `productId` of this provider.
  String? get productId;
}

class _ProductFormControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProductFormController,
        ProductDraft> with ProductFormControllerRef {
  _ProductFormControllerProviderElement(super.provider);

  @override
  String? get productId => (origin as ProductFormControllerProvider).productId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
