// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_status_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cacheStatusHash() => r'e3d6ecc19f08f5f7c24f3e58034ab25f7d27b92d';

/// Size and age of the offline catalogue, for the account screen.
///
/// Deliberately separate from the catalogue controller: this is the only place
/// that pays for the disk walk behind `approximateSizeInBytes`, and folding it
/// into the catalogue controller would make every catalogue load wait on a
/// measurement nobody outside this screen ever reads.
///
/// Copied from [cacheStatus].
@ProviderFor(cacheStatus)
final cacheStatusProvider = AutoDisposeFutureProvider<CacheStatus>.internal(
  cacheStatus,
  name: r'cacheStatusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cacheStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheStatusRef = AutoDisposeFutureProviderRef<CacheStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
