// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_complaints_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ownerComplaintQueryControllerHash() =>
    r'8942b8d08be6061fa8387aca23c206d8d1cb28c4';

/// See also [OwnerComplaintQueryController].
@ProviderFor(OwnerComplaintQueryController)
final ownerComplaintQueryControllerProvider = AutoDisposeNotifierProvider<
    OwnerComplaintQueryController, OwnerComplaintFilter>.internal(
  OwnerComplaintQueryController.new,
  name: r'ownerComplaintQueryControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ownerComplaintQueryControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OwnerComplaintQueryController
    = AutoDisposeNotifier<OwnerComplaintFilter>;
String _$ownerComplaintsControllerHash() =>
    r'72b04538608fb3f958b63597fdb92d687b351283';

/// Loads complaints list for the Owner dashboard.
///
/// Copied from [OwnerComplaintsController].
@ProviderFor(OwnerComplaintsController)
final ownerComplaintsControllerProvider = AutoDisposeAsyncNotifierProvider<
    OwnerComplaintsController, List<Complaint>>.internal(
  OwnerComplaintsController.new,
  name: r'ownerComplaintsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ownerComplaintsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OwnerComplaintsController = AutoDisposeAsyncNotifier<List<Complaint>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
