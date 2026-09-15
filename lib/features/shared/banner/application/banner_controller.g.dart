// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeBannersHash() => r'd6a5f88cdfdaebbec8cc8fae335e3b10c9dcd526';

/// Provider for active banners displayed on the User Dashboard.
///
/// Supabase is the single source of truth:
/// - Fetches active banners from `dashboard_banners` table.
/// - Returns empty list `[]` when no active banners exist.
/// - Caches fresh remote banners to disk for offline fallback.
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
    r'a92766b066340090ad0fa22cb0020abd229c89a7';

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
