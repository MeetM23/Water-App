// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$businessSettingsControllerHash() =>
    r'7e555482d0167f1177a0339abf4dc4dbef24e612';

/// The business details printed on labels and exports.
///
/// Kept alive because the label builder reads it on every print job and the
/// value changes perhaps twice a year; refetching it per sheet would be a
/// round trip for nothing.
///
/// Copied from [BusinessSettingsController].
@ProviderFor(BusinessSettingsController)
final businessSettingsControllerProvider = AsyncNotifierProvider<
    BusinessSettingsController, BusinessSettings>.internal(
  BusinessSettingsController.new,
  name: r'businessSettingsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessSettingsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BusinessSettingsController = AsyncNotifier<BusinessSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
