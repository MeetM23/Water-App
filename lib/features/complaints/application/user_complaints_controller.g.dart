// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_complaints_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userComplaintsControllerHash() =>
    r'8459da81b05160dc794786526e66e5c51b990c5f';

/// Loads and manages complaints for the logged-in dealer.
///
/// Copied from [UserComplaintsController].
@ProviderFor(UserComplaintsController)
final userComplaintsControllerProvider = AutoDisposeAsyncNotifierProvider<
    UserComplaintsController, List<Complaint>>.internal(
  UserComplaintsController.new,
  name: r'userComplaintsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userComplaintsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserComplaintsController = AutoDisposeAsyncNotifier<List<Complaint>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
