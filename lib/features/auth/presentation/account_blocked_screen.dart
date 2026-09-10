import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/theme/app_colors.dart';
import '../application/auth_controller.dart';
import '../application/session_controller.dart';
import 'widgets/account_status_view.dart';

/// Which of the two blocked states this screen is showing.
enum BlockedReason {
  /// The owner turned the application down.
  rejected,

  /// A previously approved account was paused by the owner.
  suspended,
}

/// Shown when a signed-in account has been rejected or suspended.
///
/// Suspension is checked on every redirect, so an account paused while the
/// dealer is using the app lands here on their next navigation rather than
/// continuing with stale access.
class AccountBlockedScreen extends ConsumerWidget {
  /// Creates the blocked-account screen.
  const AccountBlockedScreen({required this.reason, super.key});

  /// Whether the account was rejected or suspended.
  final BlockedReason reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final rejectionReason = session is SessionSignedIn
        ? session.profile.rejectionReason
        : null;

    final isRejected = reason == BlockedReason.rejected;

    return AccountStatusView(
      icon: isRejected
          ? Icons.do_not_disturb_on_outlined
          : Icons.pause_circle_outline_rounded,
      accent: AppColors.danger,
      title: isRejected ? l10n.rejectedTitle : l10n.suspendedTitle,
      message: isRejected ? l10n.rejectedBody : l10n.suspendedBody,
      detailLabel: isRejected ? l10n.rejectedReasonLabel : null,
      detailValue: isRejected
          ? (rejectionReason?.trim().isNotEmpty ?? false
                ? rejectionReason
                : l10n.rejectedNoReason)
          : null,
      isSigningOut: ref.watch(authControllerProvider).isLoading,
      onSignOut: () =>
          unawaited(ref.read(authControllerProvider.notifier).signOut()),
    );
  }
}
