// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_catalogue_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$catalogueCacheHash() => r'f91c6e768813354da3cf1027426983663a9c532c';

/// The application-wide [CatalogueCache].
///
/// Deliberately unimplemented here. `main()` opens the Hive boxes before the
/// first frame and overrides this provider with the ready instance, so no
/// screen can ever reach a cache whose boxes are still opening — a race that
/// would surface as an empty catalogue on a slow phone rather than as an
/// error anybody would notice.
///
/// Copied from [catalogueCache].
@ProviderFor(catalogueCache)
final catalogueCacheProvider = Provider<CatalogueCache>.internal(
  catalogueCache,
  name: r'catalogueCacheProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$catalogueCacheHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CatalogueCacheRef = ProviderRef<CatalogueCache>;
String _$cachedCatalogueSnapshotHash() =>
    r'0f005ad7aafeb3189740c80861cdc1cea663db3d';

/// Products currently held in the offline cache, for the account screen.
///
/// Copied from [cachedCatalogueSnapshot].
@ProviderFor(cachedCatalogueSnapshot)
final cachedCatalogueSnapshotProvider =
    AutoDisposeProvider<CatalogueSnapshot?>.internal(
  cachedCatalogueSnapshot,
  name: r'cachedCatalogueSnapshotProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cachedCatalogueSnapshotHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CachedCatalogueSnapshotRef = AutoDisposeProviderRef<CatalogueSnapshot?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
