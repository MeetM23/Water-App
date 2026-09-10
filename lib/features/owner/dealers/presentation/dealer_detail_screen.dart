import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_presentation.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/extensions/enum_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../domain/enums/account_status.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../domain/models/dealer_activity.dart';
import '../../../../domain/models/profile.dart';
import '../application/dealer_directory_controller.dart';
import '../application/dealer_list_controller.dart';

/// Everything the owner knows about one dealer, and everything they can do
/// about it.
class DealerDetailScreen extends ConsumerWidget {
  /// Creates the detail screen.
  const DealerDetailScreen({required this.userId, super.key});

  /// Which dealer to show.
  final String userId;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<AppFailure?> Function() action,
    String successMessage,
  ) async {
    final l10n = context.l10n;
    final failure = await action();
    if (!context.mounted) {
      return;
    }
    if (failure != null) {
      AppSnackbar.error(context, failure.title(l10n));
      return;
    }
    AppSnackbar.success(context, successMessage);
    await ref.read(dealerDetailControllerProvider(userId).notifier).refresh();
  }

  Future<void> _changeRole(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    final l10n = context.l10n;
    final target = profile.role == UserRole.wholesaler
        ? UserRole.retailer
        : UserRole.wholesaler;

    final chosen = await showModalBottomSheet<UserRole>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(Spacing.x5),
              child: Column(
                children: <Widget>[
                  Text(
                    l10n.dealerChangeRoleTitle(profile.firmName),
                    textAlign: TextAlign.center,
                    style: sheetContext.textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.x2),
                  Text(
                    l10n.dealerChangeRoleBody,
                    textAlign: TextAlign.center,
                    style: sheetContext.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                target == UserRole.wholesaler
                    ? Icons.inventory_2_outlined
                    : Icons.storefront_outlined,
              ),
              title: Text(target.label(l10n)),
              subtitle: Text(
                target == UserRole.wholesaler
                    ? l10n.roleWholesalerHelp
                    : l10n.roleRetailerHelp,
              ),
              onTap: () => Navigator.of(sheetContext).pop(target),
            ),
            const SizedBox(height: Spacing.x3),
          ],
        ),
      ),
    );

    if (chosen == null || !context.mounted) {
      return;
    }
    await _run(
      context,
      ref,
      () => ref
          .read(dealerActionControllerProvider.notifier)
          .setRole(profile.id, chosen),
      l10n.dealerRoleChanged(
        profile.firmName,
        chosen.label(l10n).toLowerCase(),
      ),
    );
  }

  Future<void> _suspend(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.dealerSuspendTitle(profile.firmName),
      message: l10n.dealerSuspendBody,
      confirmLabel: l10n.dealerSuspend,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await _run(
      context,
      ref,
      () =>
          ref.read(dealerActionControllerProvider.notifier).suspend(profile.id),
      l10n.dealerSuspendedToast(profile.firmName),
    );
  }

  Future<void> _reactivate(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.dealerReactivateTitle(profile.firmName),
      message: l10n.dealerReactivateBody,
      confirmLabel: l10n.dealerReactivate,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await _run(
      context,
      ref,
      () => ref
          .read(dealerActionControllerProvider.notifier)
          .reactivate(profile.id),
      l10n.dealerReactivatedToast(profile.firmName),
    );
  }

  Future<void> _resetPassword(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.dealerResetPasswordTitle,
      message: l10n.dealerResetPasswordBody(profile.firmName),
      confirmLabel: l10n.dealerResetPassword,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await _run(
      context,
      ref,
      () => ref
          .read(dealerActionControllerProvider.notifier)
          .sendPasswordReset(profile.id),
      l10n.dealerResetPasswordSent,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(dealerDetailControllerProvider(userId));
    final isBusy = ref.watch(dealerActionControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dealerDetailTitle)),
      body: detail.when(
        loading: () => const _DetailSkeleton(),
        error: (Object error, StackTrace stackTrace) => AppErrorState(
          failure: error is AppFailure
              ? error
              : UnexpectedFailure(cause: error, stackTrace: stackTrace),
          onRetry: () => ref
              .read(dealerDetailControllerProvider(userId).notifier)
              .refresh(),
        ),
        data: (DealerDetail value) => RefreshIndicator(
          onRefresh: () => ref
              .read(dealerDetailControllerProvider(userId).notifier)
              .refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(Spacing.x4),
            children: <Widget>[
              _Header(profile: value.profile),
              const SizedBox(height: Spacing.x5),
              _ContactCard(profile: value.profile),
              const SizedBox(height: Spacing.x5),
              _ActivityCard(activity: value.activity),
              const SizedBox(height: Spacing.x5),
              _RecordCard(profile: value.profile),
              const SizedBox(height: Spacing.x6),
              _Actions(
                profile: value.profile,
                isBusy: isBusy,
                onChangeRole: () => _changeRole(context, ref, value.profile),
                onSuspend: () => _suspend(context, ref, value.profile),
                onReactivate: () => _reactivate(context, ref, value.profile),
                onResetPassword: () =>
                    _resetPassword(context, ref, value.profile),
              ),
              const SizedBox(height: Spacing.x10),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          profile.firmName,
          style: context.textTheme.headlineSmall?.copyWith(
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: Spacing.x1),
        Text(
          profile.fullName,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: Spacing.x3),
        Wrap(
          spacing: Spacing.x2,
          runSpacing: Spacing.x2,
          children: <Widget>[
            AppBadge(label: profile.role.label(l10n), tone: AppBadgeTone.info),
            AppBadge(
              label: profile.status.label(l10n),
              tone: profile.status.tone,
            ),
          ],
        ),
        if (profile.status == AccountStatus.rejected &&
            (profile.rejectionReason?.isNotEmpty ?? false)) ...<Widget>[
          const SizedBox(height: Spacing.x3),
          Text(
            '${l10n.rejectedReasonLabel}: ${profile.rejectionReason}',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.profile});

  final Profile profile;

  Future<void> _call(BuildContext context) async {
    final launched = await ContactLauncher.call(profile.phone);
    if (!launched && context.mounted) {
      AppSnackbar.error(context, context.l10n.errorGenericTitle);
    }
  }

  Future<void> _whatsApp(BuildContext context) async {
    final launched = await ContactLauncher.whatsAppTo(profile.phone);
    if (!launched && context.mounted) {
      AppSnackbar.error(context, context.l10n.errorGenericTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Row(label: l10n.fieldPhone, value: profile.phone),
          _Row(
            label: l10n.labelCity,
            value: '${profile.city}, ${profile.state}',
          ),
          _Row(
            label: l10n.dealerAddressLabel,
            value: profile.address?.trim().isNotEmpty ?? false
                ? profile.address!
                : l10n.dealerNoAddress,
          ),
          _Row(
            label: l10n.dealerGstLabel,
            value: profile.gstNumber?.trim().isNotEmpty ?? false
                ? profile.gstNumber!
                : l10n.dealerNoGst,
          ),
          const SizedBox(height: Spacing.x2),
          Wrap(
            spacing: Spacing.x2,
            children: <Widget>[
              TextButton.icon(
                onPressed: () => _call(context),
                icon: const Icon(Icons.call_outlined, size: 18),
                label: Text(l10n.actionCall),
              ),
              TextButton.icon(
                onPressed: () => _whatsApp(context),
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: Text(l10n.actionWhatsApp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final DealerActivity activity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Row(label: l10n.dealerTotalScans, value: '${activity.totalScans}'),
          _Row(
            label: l10n.dealerLastActive,
            value: activity.lastActive == null
                ? l10n.dealerNeverActive
                : RelativeTime.format(l10n, activity.lastActive!),
          ),
          if (activity.hasNeverUsedTheApp) ...<Widget>[
            const SizedBox(height: Spacing.x2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: Spacing.x2),
                Expanded(
                  child: Text(
                    l10n.dealerNeverActive,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = DateFormat.yMMMMd();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Row(
            label: l10n.dealerRegisteredOn,
            value: date.format(profile.createdAt),
          ),
          if (profile.approvedAt != null)
            _Row(
              label: l10n.dealerApprovedOn,
              value: date.format(profile.approvedAt!),
            ),
          // approved_by is always the owner: it is the only account the RPCs
          // let make this decision. Naming them "You" is honest and avoids a
          // second profile fetch to render a name the owner already knows.
          if (profile.approvedAt != null)
            _Row(label: l10n.dealerApprovedBy, value: l10n.dealerApprovedByYou),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.profile,
    required this.isBusy,
    required this.onChangeRole,
    required this.onSuspend,
    required this.onReactivate,
    required this.onResetPassword,
  });

  final Profile profile;
  final bool isBusy;
  final VoidCallback onChangeRole;
  final VoidCallback onSuspend;
  final VoidCallback onReactivate;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isApproved = profile.status == AccountStatus.approved;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (isApproved)
          AppButton(
            label: l10n.dealerChangeRole,
            onPressed: isBusy ? null : onChangeRole,
            icon: Icons.swap_horiz_rounded,
            variant: AppButtonVariant.secondary,
          ),
        if (isApproved) const SizedBox(height: Spacing.x3),
        AppButton(
          label: l10n.dealerResetPassword,
          onPressed: isBusy ? null : onResetPassword,
          icon: Icons.mail_outline_rounded,
          variant: AppButtonVariant.secondary,
        ),
        const SizedBox(height: Spacing.x3),
        if (isApproved)
          AppButton(
            label: l10n.dealerSuspend,
            onPressed: isBusy ? null : onSuspend,
            variant: AppButtonVariant.danger,
          )
        else
          AppButton(
            label: l10n.dealerReactivate,
            onPressed: isBusy ? null : onReactivate,
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: Padding(
        padding: EdgeInsets.all(Spacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSkeleton(width: 220, height: 24),
            SizedBox(height: Spacing.x3),
            AppSkeleton(width: 140, height: 12),
            SizedBox(height: Spacing.x5),
            AppSkeleton(height: 150),
            SizedBox(height: Spacing.x5),
            AppSkeleton(height: 90),
          ],
        ),
      ),
    );
  }
}
