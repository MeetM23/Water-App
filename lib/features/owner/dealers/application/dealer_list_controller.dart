import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../data/repositories/supabase_dealer_repository.dart';
import '../../../../domain/enums/account_status.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../domain/models/profile.dart';
import '../../dashboard/application/dashboard_controller.dart';
import 'approval_queue_controller.dart';
import 'dealer_directory_controller.dart';

part 'dealer_list_controller.g.dart';

/// Loads the dealers sitting in one approval state.
@riverpod
class DealerListController extends _$DealerListController {
  @override
  Future<List<Profile>> build(AccountStatus status) async {
    final result = await ref
        .read(dealerRepositoryProvider)
        .fetchByStatus(status);
    return result.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw failure,
    );
  }

  /// Reloads this tab.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Runs the owner-only dealer decisions.
///
/// Each call reaches a SECURITY DEFINER routine that re-checks `is_owner()`
/// server side, so a compromised client cannot approve anybody. The loading
/// flag here is what keeps a double tap from firing two approvals.
@riverpod
class DealerActionController extends _$DealerActionController {
  @override
  FutureOr<void> build() {}

  /// Approves a dealer into [role].
  Future<AppFailure?> approve(String userId, UserRole role) =>
      _run(() => ref.read(dealerRepositoryProvider).approve(userId, role));

  /// Rejects a dealer with a written reason.
  Future<AppFailure?> reject(String userId, String reason) =>
      _run(() => ref.read(dealerRepositoryProvider).reject(userId, reason));

  /// Suspends an approved dealer.
  Future<AppFailure?> suspend(String userId) =>
      _run(() => ref.read(dealerRepositoryProvider).suspend(userId));

  /// Restores a suspended or rejected dealer.
  Future<AppFailure?> reactivate(String userId) =>
      _run(() => ref.read(dealerRepositoryProvider).reactivate(userId));

  /// Moves an approved dealer between wholesaler and retailer.
  Future<AppFailure?> setRole(String userId, UserRole role) =>
      _run(() => ref.read(dealerRepositoryProvider).setRole(userId, role));

  /// Emails a password-reset link to the dealer's own address.
  ///
  /// The address is fetched through an owner-only routine rather than stored
  /// on the profile, so the owner never handles it and it is never cached on
  /// the device.
  Future<AppFailure?> sendPasswordReset(String userId) async {
    if (state.isLoading) {
      return null;
    }
    state = const AsyncValue<void>.loading();

    final repository = ref.read(dealerRepositoryProvider);
    final email = await repository.emailFor(userId);

    final emailFailure = email.failureOrNull;
    if (emailFailure != null) {
      state = AsyncValue<void>.error(emailFailure, StackTrace.current);
      return emailFailure;
    }

    final sent = await repository.sendPasswordReset(email.valueOrNull!);
    final failure = sent.failureOrNull;

    state = failure == null
        ? const AsyncValue<void>.data(null)
        : AsyncValue<void>.error(failure, StackTrace.current);
    return failure;
  }

  Future<AppFailure?> _run(Future<Result<Profile>> Function() action) async {
    if (state.isLoading) {
      return null;
    }

    state = const AsyncValue<void>.loading();
    final failure = (await action()).failureOrNull;

    state = failure == null
        ? const AsyncValue<void>.data(null)
        : AsyncValue<void>.error(failure, StackTrace.current);

    if (failure == null) {
      // One decision moves a dealer between tabs and changes two dashboard
      // cards, so every dependent view is dropped rather than trying to patch
      // each of them by hand.
      for (final status in AccountStatus.values) {
        ref.invalidate(dealerListControllerProvider(status));
      }
      ref
        ..invalidate(dealerDirectoryControllerProvider)
        ..invalidate(approvalQueueControllerProvider)
        ..invalidate(dealerCountsCardProvider)
        ..invalidate(dealerActivityCardProvider);
    }
    return failure;
  }
}
