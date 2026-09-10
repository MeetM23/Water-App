// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeBannersHash() => r'6d902b639d0e410c21617175a7df2537b29d848e';

/// Provider for active banners displayed on the User Dashboard.
///
/// Designed to be completely stable and fail-safe:
/// - Keep alive in memory (`keepAlive: true`).
/// - Synchronously initialised with a stable default list.
/// - Performs an async fetch once in the background.
/// - Never enters an infinite loading or rebuild loop.
///
/// Copied from [ActiveBanners].
@ProviderFor(ActiveBanners)
final activeBannersProvider =
    NotifierProvider<ActiveBanners, List<DashboardBanner>>.internal(
  ActiveBanners.new,
  name: r'activeBannersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeBannersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveBanners = Notifier<List<DashboardBanner>>;
String _$adminBannersControllerHash() =>
    r'f0a01efedb64e8a6098ee4288f9711dec5b58715';

/// Controller managing all banners for Admin Banner Management.
///
/// Copied from [AdminBannersController].
@ProviderFor(AdminBannersController)
final adminBannersControllerProvider = AutoDisposeAsyncNotifierProvider<
    AdminBannersController, List<DashboardBanner>>.internal(
  AdminBannersController.new,
  name: r'adminBannersControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminBannersControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdminBannersController
    = AutoDisposeAsyncNotifier<List<DashboardBanner>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
