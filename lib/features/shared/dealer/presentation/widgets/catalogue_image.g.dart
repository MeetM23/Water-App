// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_image.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$catalogueImageBytesHash() =>
    r'd85f1bfe1105faeacd11049df67980b457faff4f';

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

/// Bytes for one catalogue image, cache first.
///
/// Deliberately NOT `cached_network_image`. That package keys its disk cache
/// by URL, and every URL here is a signed URL that expires within the hour —
/// so on the cold offline start this whole feature exists for, every key is a
/// miss and every image is blank. Keying by storage path instead means the
/// bytes survive the signature.
///
/// Copied from [catalogueImageBytes].
@ProviderFor(catalogueImageBytes)
const catalogueImageBytesProvider = CatalogueImageBytesFamily();

/// Bytes for one catalogue image, cache first.
///
/// Deliberately NOT `cached_network_image`. That package keys its disk cache
/// by URL, and every URL here is a signed URL that expires within the hour —
/// so on the cold offline start this whole feature exists for, every key is a
/// miss and every image is blank. Keying by storage path instead means the
/// bytes survive the signature.
///
/// Copied from [catalogueImageBytes].
class CatalogueImageBytesFamily extends Family<AsyncValue<Uint8List?>> {
  /// Bytes for one catalogue image, cache first.
  ///
  /// Deliberately NOT `cached_network_image`. That package keys its disk cache
  /// by URL, and every URL here is a signed URL that expires within the hour —
  /// so on the cold offline start this whole feature exists for, every key is a
  /// miss and every image is blank. Keying by storage path instead means the
  /// bytes survive the signature.
  ///
  /// Copied from [catalogueImageBytes].
  const CatalogueImageBytesFamily();

  /// Bytes for one catalogue image, cache first.
  ///
  /// Deliberately NOT `cached_network_image`. That package keys its disk cache
  /// by URL, and every URL here is a signed URL that expires within the hour —
  /// so on the cold offline start this whole feature exists for, every key is a
  /// miss and every image is blank. Keying by storage path instead means the
  /// bytes survive the signature.
  ///
  /// Copied from [catalogueImageBytes].
  CatalogueImageBytesProvider call(
    String storagePath,
  ) {
    return CatalogueImageBytesProvider(
      storagePath,
    );
  }

  @override
  CatalogueImageBytesProvider getProviderOverride(
    covariant CatalogueImageBytesProvider provider,
  ) {
    return call(
      provider.storagePath,
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
  String? get name => r'catalogueImageBytesProvider';
}

/// Bytes for one catalogue image, cache first.
///
/// Deliberately NOT `cached_network_image`. That package keys its disk cache
/// by URL, and every URL here is a signed URL that expires within the hour —
/// so on the cold offline start this whole feature exists for, every key is a
/// miss and every image is blank. Keying by storage path instead means the
/// bytes survive the signature.
///
/// Copied from [catalogueImageBytes].
class CatalogueImageBytesProvider
    extends AutoDisposeFutureProvider<Uint8List?> {
  /// Bytes for one catalogue image, cache first.
  ///
  /// Deliberately NOT `cached_network_image`. That package keys its disk cache
  /// by URL, and every URL here is a signed URL that expires within the hour —
  /// so on the cold offline start this whole feature exists for, every key is a
  /// miss and every image is blank. Keying by storage path instead means the
  /// bytes survive the signature.
  ///
  /// Copied from [catalogueImageBytes].
  CatalogueImageBytesProvider(
    String storagePath,
  ) : this._internal(
          (ref) => catalogueImageBytes(
            ref as CatalogueImageBytesRef,
            storagePath,
          ),
          from: catalogueImageBytesProvider,
          name: r'catalogueImageBytesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$catalogueImageBytesHash,
          dependencies: CatalogueImageBytesFamily._dependencies,
          allTransitiveDependencies:
              CatalogueImageBytesFamily._allTransitiveDependencies,
          storagePath: storagePath,
        );

  CatalogueImageBytesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.storagePath,
  }) : super.internal();

  final String storagePath;

  @override
  Override overrideWith(
    FutureOr<Uint8List?> Function(CatalogueImageBytesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CatalogueImageBytesProvider._internal(
        (ref) => create(ref as CatalogueImageBytesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        storagePath: storagePath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Uint8List?> createElement() {
    return _CatalogueImageBytesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogueImageBytesProvider &&
        other.storagePath == storagePath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storagePath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CatalogueImageBytesRef on AutoDisposeFutureProviderRef<Uint8List?> {
  /// The parameter `storagePath` of this provider.
  String get storagePath;
}

class _CatalogueImageBytesProviderElement
    extends AutoDisposeFutureProviderElement<Uint8List?>
    with CatalogueImageBytesRef {
  _CatalogueImageBytesProviderElement(super.provider);

  @override
  String get storagePath => (origin as CatalogueImageBytesProvider).storagePath;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
