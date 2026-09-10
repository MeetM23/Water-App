// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authUserIdHash() => r'061c8af92362dbe1d167b6bbf9b84ca00a5a25de';

/// The current user id, or null when signed out.
///
/// Copied from [authUserId].
@ProviderFor(authUserId)
final authUserIdProvider = StreamProvider<String?>.internal(
  authUserId,
  name: r'authUserIdProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthUserIdRef = StreamProviderRef<String?>;
String _$sessionControllerHash() => r'5d161a13563a65b414cde7a1bec3d780b7885d40';

/// Resolves the signed-in user into a [SessionState] the router can act on.
///
/// While this is loading the router holds the user on the splash screen, so no
/// screen is ever shown to the wrong role even for a frame.
///
/// Copied from [SessionController].
@ProviderFor(SessionController)
final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, SessionState>.internal(
  SessionController.new,
  name: r'sessionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionController = AsyncNotifier<SessionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
