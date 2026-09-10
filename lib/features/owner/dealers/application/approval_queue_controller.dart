import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../data/repositories/supabase_dealer_repository.dart';
import '../../../../domain/enums/account_status.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../domain/models/profile.dart';
import '../../dashboard/application/dashboard_controller.dart';
import 'dealer_directory_controller.dart';
import 'dealer_list_controller.dart';

part 'approval_queue_controller.g.dart';

/// The dealers waiting on a decision.
///
/// Decisions are applied optimistically: the card leaves the queue the instant
/// the owner taps, because the owner is usually working through a batch and a
/// two-second wait per dealer turns a one-minute job into five. If the RPC
/// fails the card is put back exactly where it was and the failure is
/// surfaced, so an optimistic update can never be mistaken for a real one.
@riverpod
class ApprovalQueueController extends _$ApprovalQueueController {
  @override
  Future<List<Profile>> build() async {
    final result = await ref
        .read(dealerRepositoryProvider)
        .fetchByStatus(AccountStatus.pending);
    return result.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw failure,
    );
  }

  /// Reloads the queue from the server.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Approves [profile] into [role], removing the card immediately.
  Future<AppFailure?> approve(Profile profile, UserRole role) => _decide(
    profile,
    () => ref.read(dealerRepositoryProvider).approve(profile.id, role),
  );

  /// Rejects [profile] with [reason], removing the card immediately.
  Future<AppFailure?> reject(Profile profile, String reason) => _decide(
    profile,
    () => ref.read(dealerRepositoryProvider).reject(profile.id, reason),
  );

  Future<AppFailure?> _decide(
    Profile profile,
    Future<Result<Profile>> Function() action,
  ) async {
    final current = state.valueOrNull;
    if (current == null) {
      return null;
    }

    final index = current.indexWhere((Profile p) => p.id == profile.id);
    if (index < 0) {
      // Already decided, most likely a double tap. Doing nothing is the right
      // answer: the first tap is still in flight.
      return null;
    }

    state = AsyncValue<List<Profile>>.data(
      <Profile>[...current]..removeAt(index),
    );

    final failure = (await action()).failureOrNull;

    if (failure != null) {
      // Put the dealer back where they were, not on the end: the owner is
      // reading down a list and a card that reappears elsewhere looks like a
      // different dealer.
      final rolledBack = <Profile>[...state.valueOrNull ?? <Profile>[]];
      rolledBack.insert(index.clamp(0, rolledBack.length), profile);
      state = AsyncValue<List<Profile>>.data(rolledBack);
      return failure;
    }

    _invalidateDependents();
    return null;
  }

  /// Drops every view that a decision changes.
  ///
  /// A decision moves a dealer between lists, changes two dashboard cards and
  /// adds an audit entry, so patching each by hand would be four chances to
  /// leave one stale.
  void _invalidateDependents() {
    for (final status in AccountStatus.values) {
      ref.invalidate(dealerListControllerProvider(status));
    }
    ref
      ..invalidate(dealerDirectoryControllerProvider)
      ..invalidate(dealerCountsCardProvider)
      ..invalidate(dealerActivityCardProvider);
  }
}

/// The pending count behind the badge on the Dealers tab.
///
/// Derived from the queue itself rather than counted separately, so an
/// optimistic approval clears the badge at the same instant it removes the
/// card. Two independent queries would show a decremented list beside a stale
/// badge for as long as the round trip takes.
@riverpod
int pendingDealerCount(Ref<int> ref) =>
    ref.watch(approvalQueueControllerProvider).valueOrNull?.length ?? 0;
