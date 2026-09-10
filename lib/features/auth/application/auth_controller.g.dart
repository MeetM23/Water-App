// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authControllerHash() => r'71aa410d0b4f932ba314dd3e31d5b0c0a194eabb';

/// Drives the sign-in, sign-up and sign-out forms.
///
/// The controller owns the in-flight flag that disables submit buttons, which
/// is what makes a double submit impossible: the second tap arrives while
/// `state.isLoading` is true and the button is already disabled.
///
/// Each action returns the [AppFailure] to show, or null on success. Routing
/// after a successful sign-in is not done here: the session stream updates and
/// the router redirect reacts to it.
///
/// Copied from [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>.internal(
  AuthController.new,
  name: r'authControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
