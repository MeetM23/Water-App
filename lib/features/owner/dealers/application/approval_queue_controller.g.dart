// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval_queue_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingDealerCountHash() =>
    r'b7ff279ffb713ad19ee4d27013e3a3b8f7080b48';

/// The pending count behind the badge on the Dealers tab.
///
/// Derived from the queue itself rather than counted separately, so an
/// optimistic approval clears the badge at the same instant it removes the
/// card. Two independent queries would show a decremented list beside a stale
/// badge for as long as the round trip takes.
///
/// Copied from [pendingDealerCount].
@ProviderFor(pendingDealerCount)
final pendingDealerCountProvider = AutoDisposeProvider<int>.internal(
  pendingDealerCount,
  name: r'pendingDealerCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingDealerCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingDealerCountRef = AutoDisposeProviderRef<int>;
String _$approvalQueueControllerHash() =>
    r'21acaf9641783a49253427eb92b9428971c2ea84';

/// The dealers waiting on a decision.
///
/// Decisions are applied optimistically: the card leaves the queue the instant
/// the owner taps, because the owner is usually working through a batch and a
/// two-second wait per dealer turns a one-minute job into five. If the RPC
/// fails the card is put back exactly where it was and the failure is
/// surfaced, so an optimistic update can never be mistaken for a real one.
///
/// Copied from [ApprovalQueueController].
@ProviderFor(ApprovalQueueController)
final approvalQueueControllerProvider = AutoDisposeAsyncNotifierProvider<
    ApprovalQueueController, List<Profile>>.internal(
  ApprovalQueueController.new,
  name: r'approvalQueueControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$approvalQueueControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ApprovalQueueController = AutoDisposeAsyncNotifier<List<Profile>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
