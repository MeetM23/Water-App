import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../domain/models/profile.dart';
import '../application/approval_queue_controller.dart';
import 'widgets/approve_dealer_sheet.dart';
import 'widgets/reject_dealer_sheet.dart';

/// The dealers waiting on a decision.
///
/// This is the screen the client opens first every morning, so it is built
/// around deciding rather than browsing: everything needed to judge a request
/// is on the card, and calling the applicant is one tap away because the
/// honest answer to half of these is "ring them and ask".
class ApprovalQueueScreen extends ConsumerWidget {
  /// Creates the queue.
  const ApprovalQueueScreen({super.key});

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    final role = await ApproveDealerSheet.show(context, profile: profile);
    if (role == null || !context.mounted) {
      return;
    }

    final l10n = context.l10n;
    final failure = await ref
        .read(approvalQueueControllerProvider.notifier)
        .approve(profile, role);

    if (!context.mounted) {
      return;
    }
    if (failure == null) {
      AppSnackbar.success(context, l10n.dealerApproved(profile.firmName));
    } else {
      AppSnackbar.error(context, failure.title(l10n));
    }
  }

  Future<void> _reject(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    final outcome = await RejectDealerSheet.show(context, profile: profile);
    if (outcome == null || !context.mounted) {
      return;
    }

    final l10n = context.l10n;
    final failure = await ref
        .read(approvalQueueControllerProvider.notifier)
        .reject(profile, outcome.message(l10n));

    if (!context.mounted) {
      return;
    }
    if (failure == null) {
      AppSnackbar.success(context, l10n.dealerRejectedToast(profile.firmName));
    } else {
      AppSnackbar.error(context, failure.title(l10n));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final queue = ref.watch(approvalQueueControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requestsTitle)),
      body: queue.when(
        loading: () => const _QueueSkeleton(),
        error: (Object error, StackTrace stackTrace) => AppErrorState(
          failure: error is AppFailure
              ? error
              : UnexpectedFailure(cause: error, stackTrace: stackTrace),
          onRetry: () =>
              ref.read(approvalQueueControllerProvider.notifier).refresh(),
        ),
        data: (List<Profile> pending) => RefreshIndicator(
          onRefresh: () =>
              ref.read(approvalQueueControllerProvider.notifier).refresh(),
          child: pending.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: <Widget>[
                    ConstrainedBox(
                      // A minimum, not a fixed height: at a large system text
                      // scale the content is taller than this and must be
                      // allowed to grow into the scroll view rather than
                      // overflow inside a box that cannot hold it.
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height * 0.6,
                      ),
                      child: AppEmptyState(
                        icon: Icons.inbox_outlined,
                        title: l10n.requestsEmptyTitle,
                        message: l10n.requestsEmptyBody,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(Spacing.x4),
                  itemCount: pending.length + 1,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: Spacing.x3),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.x1),
                        child: Text(
                          l10n.requestsSubtitle(pending.length),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    final profile = pending[index - 1];
                    return _RequestCard(
                      profile: profile,
                      onApprove: () => _approve(context, ref, profile),
                      onReject: () => _reject(context, ref, profile),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.profile,
    required this.onApprove,
    required this.onReject,
  });

  final Profile profile;
  final VoidCallback onApprove;
  final VoidCallback onReject;

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
          Text(
            profile.firmName,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
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
              AppBadge(
                label: '${l10n.requestedRole}: ${profile.role.label(l10n)}',
                // Amber, not blue: a self-selected wholesaler role is the one
                // thing on this card the owner must actually look at.
                tone: profile.role == UserRole.wholesaler
                    ? AppBadgeTone.warning
                    : AppBadgeTone.neutral,
              ),
              AppBadge(
                label: l10n.requestsTimeAgo(
                  RelativeTime.format(l10n, profile.createdAt),
                ),
                tone: AppBadgeTone.neutral,
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
          const SizedBox(height: Spacing.x4),
          _Field(label: l10n.labelCity, value: profile.city),
          _Field(
            label: l10n.dealerGstLabel,
            value: profile.gstNumber?.trim().isNotEmpty ?? false
                ? profile.gstNumber!
                : l10n.dealerNoGst,
          ),
          const SizedBox(height: Spacing.x3),
          _ContactRow(
            phone: profile.phone,
            onCall: () => _call(context),
            onWhatsApp: () => _whatsApp(context),
          ),
          const Divider(height: Spacing.x6),
          // Reject sits left and quiet, approve right and prominent: the
          // common answer should be the easy one, and the irreversible-feeling
          // one should never be the button under a wandering thumb.
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: l10n.dealerReject,
                  onPressed: onReject,
                  variant: AppButtonVariant.secondary,
                ),
              ),
              const SizedBox(width: Spacing.x3),
              Expanded(
                child: AppButton(
                  label: l10n.dealerApprove,
                  onPressed: onApprove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.phone,
    required this.onCall,
    required this.onWhatsApp,
  });

  final String phone;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      spacing: Spacing.x2,
      runSpacing: Spacing.x2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          phone,
          style: context.textTheme.bodyMedium?.copyWith(color: AppColors.ink),
        ),
        TextButton.icon(
          onPressed: onCall,
          icon: const Icon(Icons.call_outlined, size: 18),
          label: Text(l10n.actionCall),
        ),
        TextButton.icon(
          onPressed: onWhatsApp,
          icon: const Icon(Icons.chat_outlined, size: 18),
          label: Text(l10n.actionWhatsApp),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

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
            width: 84,
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

class _QueueSkeleton extends StatelessWidget {
  const _QueueSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(Spacing.x4),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
        itemBuilder: (_, __) => const AppSkeleton(height: 224),
      ),
    );
  }
}
