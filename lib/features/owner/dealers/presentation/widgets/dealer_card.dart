import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/app_failure.dart';
import '../../../../../core/errors/failure_presentation.dart';
import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/extensions/enum_labels.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_badge.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../domain/enums/account_status.dart';
import '../../../../../domain/enums/user_role.dart';
import '../../../../../domain/models/profile.dart';
import '../../application/dealer_list_controller.dart';

/// One dealer, with the decisions available in their current state.
///
/// Approving asks which role first, because that single choice decides which
/// price list the dealer will see for the rest of the relationship.
class DealerCard extends ConsumerWidget {
  /// Creates a dealer card.
  const DealerCard({required this.profile, super.key});

  /// The dealer being shown.
  final Profile profile;

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final role = await showModalBottomSheet<UserRole>(
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
                    l10n.dealerApproveTitle,
                    style: sheetContext.textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.x2),
                  Text(
                    l10n.dealerApproveBody(profile.fullName),
                    textAlign: TextAlign.center,
                    style: sheetContext.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(l10n.roleWholesaler),
              subtitle: Text(l10n.roleWholesalerHelp),
              onTap: () => Navigator.of(sheetContext).pop(UserRole.wholesaler),
            ),
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(l10n.roleRetailer),
              subtitle: Text(l10n.roleRetailerHelp),
              onTap: () => Navigator.of(sheetContext).pop(UserRole.retailer),
            ),
            const SizedBox(height: Spacing.x3),
          ],
        ),
      ),
    );

    if (role == null || !context.mounted) {
      return;
    }
    await _run(
      context,
      ref,
      () => ref
          .read(dealerActionControllerProvider.notifier)
          .approve(profile.id, role),
      l10n.dealerApproved(profile.fullName),
    );
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.dealerRejectTitle(profile.fullName)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.dealerRejectBody),
            const SizedBox(height: Spacing.x4),
            AppTextField(
              label: l10n.dealerRejectReason,
              controller: controller,
              hint: l10n.dealerRejectReasonHint,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.dealerReject),
          ),
        ],
      ),
    );

    final reason = controller.text.trim();
    controller.dispose();

    if (confirmed != true || !context.mounted) {
      return;
    }
    if (reason.isEmpty) {
      AppSnackbar.error(
        context,
        l10n.validationRequired(l10n.dealerRejectReason),
      );
      return;
    }

    await _run(
      context,
      ref,
      () => ref
          .read(dealerActionControllerProvider.notifier)
          .reject(profile.id, reason),
      l10n.dealerRejectedToast(profile.fullName),
    );
  }

  Future<void> _suspend(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.dealerSuspendTitle(profile.fullName),
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
      l10n.dealerSuspendedToast(profile.fullName),
    );
  }

  Future<void> _reactivate(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.dealerReactivateTitle(profile.fullName),
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
      l10n.dealerReactivatedToast(profile.fullName),
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<AppFailure?> Function() action,
    String successMessage,
  ) async {
    final failure = await action();
    if (!context.mounted) {
      return;
    }
    if (failure == null) {
      AppSnackbar.success(context, successMessage);
    } else {
      AppSnackbar.error(context, failure.title(context.l10n));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isBusy = ref.watch(dealerActionControllerProvider).isLoading;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      profile.firmName,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.fullName,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: profile.status.label(l10n),
                tone: profile.status.tone,
              ),
            ],
          ),
          const SizedBox(height: Spacing.x3),
          _InfoRow(label: l10n.fieldPhone, value: profile.phone),
          _InfoRow(
            label: l10n.labelCity,
            value: '${profile.city}, ${profile.state}',
          ),
          _InfoRow(
            label: l10n.dealerGstLabel,
            value: profile.gstNumber?.isNotEmpty ?? false
                ? profile.gstNumber!
                : l10n.dealerNoGst,
          ),
          if (profile.status == AccountStatus.rejected &&
              (profile.rejectionReason?.isNotEmpty ?? false))
            _InfoRow(
              label: l10n.rejectedReasonLabel,
              value: profile.rejectionReason!,
            ),
          const SizedBox(height: Spacing.x4),
          _Actions(
            status: profile.status,
            isBusy: isBusy,
            onApprove: () => _approve(context, ref),
            onReject: () => _reject(context, ref),
            onSuspend: () => _suspend(context, ref),
            onReactivate: () => _reactivate(context, ref),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.x1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.status,
    required this.isBusy,
    required this.onApprove,
    required this.onReject,
    required this.onSuspend,
    required this.onReactivate,
  });

  final AccountStatus status;
  final bool isBusy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSuspend;
  final VoidCallback onReactivate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return switch (status) {
      AccountStatus.pending => Row(
        children: <Widget>[
          Expanded(
            child: AppButton(
              label: l10n.dealerReject,
              onPressed: isBusy ? null : onReject,
              variant: AppButtonVariant.secondary,
            ),
          ),
          const SizedBox(width: Spacing.x3),
          Expanded(
            child: AppButton(
              label: l10n.dealerApprove,
              onPressed: isBusy ? null : onApprove,
            ),
          ),
        ],
      ),
      AccountStatus.approved => AppButton(
        label: l10n.dealerSuspend,
        onPressed: isBusy ? null : onSuspend,
        variant: AppButtonVariant.secondary,
      ),
      AccountStatus.rejected || AccountStatus.suspended => AppButton(
        label: l10n.dealerReactivate,
        onPressed: isBusy ? null : onReactivate,
        variant: AppButtonVariant.secondary,
      ),
    };
  }
}
