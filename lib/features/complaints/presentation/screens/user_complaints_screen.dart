import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/enums/complaint_priority.dart';
import '../../../../domain/enums/complaint_status.dart';
import '../../../../domain/models/complaint.dart';
import '../../application/user_complaints_controller.dart';

/// Screen listing complaints submitted by the dealer.
class UserComplaintsScreen extends ConsumerWidget {
  /// Creates the complaints screen.
  const UserComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final complaintsAsync = ref.watch(userComplaintsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.complaintsTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createComplaint),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.complaintNewButton),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: complaintsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.x6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
                const SizedBox(height: Spacing.x3),
                Text(l10n.errorGenericTitle, style: context.textTheme.titleMedium),
                const SizedBox(height: Spacing.x2),
                AppButton(
                  label: 'Retry',
                  onPressed: () => ref.read(userComplaintsControllerProvider.notifier).refresh(),
                  isExpanded: false,
                ),
              ],
            ),
          ),
        ),
        data: (complaints) {
          if (complaints.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.x6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.assignment_outlined, size: 56, color: AppColors.textSecondary),
                    const SizedBox(height: Spacing.x4),
                    Text(
                      l10n.complaintEmptyTitle,
                      style: context.textTheme.titleMedium?.copyWith(color: AppColors.ink),
                    ),
                    const SizedBox(height: Spacing.x2),
                    Text(
                      l10n.complaintEmptyBody,
                      style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.x6),
                    AppButton(
                      label: l10n.complaintNewButton,
                      onPressed: () => context.push(AppRoutes.createComplaint),
                      isExpanded: false,
                      icon: Icons.add_rounded,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(userComplaintsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(Spacing.x4),
              itemCount: complaints.length,
              separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
              itemBuilder: (BuildContext context, int index) {
                final complaint = complaints[index];
                return _ComplaintCard(complaint: complaint);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.complaintDetailPath(complaint.id)),
      padding: const EdgeInsets.all(Spacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  complaint.ticketNumber,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              _StatusChip(status: complaint.status),
            ],
          ),
          const SizedBox(height: Spacing.x3),
          Text(
            complaint.subject,
            style: context.textTheme.titleMedium?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: Spacing.x1),
          Text(
            complaint.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: Spacing.x3),
          Row(
            children: <Widget>[
              _PriorityBadge(priority: complaint.priority),
              const SizedBox(width: Spacing.x2),
              if (complaint.product != null)
                Expanded(
                  child: Text(
                    complaint.product!.name,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ComplaintStatus.open => (AppColors.primary, 'Open'),
      ComplaintStatus.inProgress => (Colors.amber.shade800, 'In Progress'),
      ComplaintStatus.resolved => (Colors.green.shade700, 'Resolved'),
      ComplaintStatus.closed => (AppColors.textSecondary, 'Closed'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final ComplaintPriority priority;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (priority) {
      ComplaintPriority.low => (Colors.grey.shade700, 'Low'),
      ComplaintPriority.medium => (Colors.blue.shade700, 'Medium'),
      ComplaintPriority.high => (Colors.orange.shade800, 'High'),
      ComplaintPriority.urgent => (Colors.red.shade700, 'Urgent'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
