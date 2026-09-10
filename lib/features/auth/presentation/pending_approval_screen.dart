import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../domain/enums/account_status.dart';
import '../application/auth_controller.dart';
import '../application/session_controller.dart';
import 'widgets/account_status_view.dart';

/// Shown to a signed-in dealer whose account the owner has not decided on.
class PendingApprovalScreen extends ConsumerStatefulWidget {
  /// Creates the pending-approval screen.
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() =>
      _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  bool _isChecking = false;

  /// Re-reads the profile. If the owner has approved in the meantime, the
  /// router redirect takes the user onward without any navigation here; if not,
  /// the user is told plainly that nothing has changed yet.
  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);

    await ref.read(sessionControllerProvider.notifier).reload();

    if (!mounted) {
      return;
    }

    setState(() => _isChecking = false);

    final session = ref.read(sessionControllerProvider).valueOrNull;
    final isStillPending =
        session is SessionSignedIn &&
        session.profile.status == AccountStatus.pending;

    if (isStillPending) {
      AppSnackbar.show(context, context.l10n.pendingStillWaiting);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final firmName = session is SessionSignedIn
        ? session.profile.firmName
        : null;

    return AccountStatusView(
      icon: Icons.hourglass_top_rounded,
      accent: AppColors.warning,
      title: l10n.pendingTitle,
      message: l10n.pendingBody,
      detailLabel: firmName == null ? null : l10n.pendingFirmLabel,
      detailValue: firmName,
      primaryActionLabel: l10n.pendingCheckStatus,
      onPrimaryAction: _checkStatus,
      isPrimaryActionLoading: _isChecking,
      isSigningOut: ref.watch(authControllerProvider).isLoading,
      onSignOut: () =>
          unawaited(ref.read(authControllerProvider.notifier).signOut()),
    );
  }
}
