// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeBannersHash() => r'00ccc86ab7e65c2b669d092e140a51266a742f93';

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
    r'da67197a5f90d35f8411bc1e281d1985acf13109';

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
