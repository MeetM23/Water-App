import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:maruti_water/core/errors/failure_presentation.dart';
import 'package:maruti_water/core/extensions/build_context_x.dart';
import 'package:maruti_water/core/theme/app_colors.dart';
import 'package:maruti_water/core/theme/app_spacing.dart';
import 'package:maruti_water/core/widgets/app_card.dart';
import 'package:maruti_water/core/widgets/app_snackbar.dart';
import 'package:maruti_water/domain/enums/complaint_priority.dart';
import 'package:maruti_water/domain/enums/complaint_status.dart';
import 'package:maruti_water/features/complaints/application/complaint_detail_controller.dart';
import '../../application/owner_complaints_controller.dart';

/// Owner detail screen for inspecting complaint, changing status/priority, and posting responses/internal notes.
class OwnerComplaintDetailScreen extends ConsumerStatefulWidget {
  /// Creates the detail screen.
  const OwnerComplaintDetailScreen({required this.complaintId, super.key});

  final String complaintId;

  @override
  ConsumerState<OwnerComplaintDetailScreen> createState() => _OwnerComplaintDetailScreenState();
}

class _OwnerComplaintDetailScreenState extends ConsumerState<OwnerComplaintDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isInternal = false;
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    final failure = await ref
        .read(complaintDetailControllerProvider(widget.complaintId).notifier)
        .sendMessage(text, isInternal: _isInternal);

    if (!mounted) return;
    setState(() => _isSending = false);

    if (failure != null) {
      AppSnackbar.error(context, failure.title(context.l10n));
    } else {
      _messageController.clear();
      ref.invalidate(ownerComplaintsControllerProvider);
    }
  }

  Future<void> _updateStatus(ComplaintStatus newStatus) async {
    final failure = await ref
        .read(complaintDetailControllerProvider(widget.complaintId).notifier)
        .updateStatusAndPriority(status: newStatus);

    if (failure != null && mounted) {
      AppSnackbar.error(context, failure.title(context.l10n));
    } else {
      ref.invalidate(ownerComplaintsControllerProvider);
    }
  }

  Future<void> _updatePriority(ComplaintPriority newPriority) async {
    final failure = await ref
        .read(complaintDetailControllerProvider(widget.complaintId).notifier)
        .updateStatusAndPriority(priority: newPriority);

    if (failure != null && mounted) {
      AppSnackbar.error(context, failure.title(context.l10n));
    } else {
      ref.invalidate(ownerComplaintsControllerProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final complaintAsync = ref.watch(complaintDetailControllerProvider(widget.complaintId));

    return Scaffold(
      appBar: AppBar(
        title: complaintAsync.when(
          data: (c) => Text('Admin: ${c.ticketNumber}'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
      ),
      body: complaintAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorGenericTitle)),
        data: (complaint) {
          final dealer = complaint.userProfile;

          return Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Admin Control Panel Card
                      AppCard(
                        padding: const EdgeInsets.all(Spacing.x4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Manage Ticket Status & Priority',
                                style: context.textTheme.titleMedium?.copyWith(color: AppColors.ink)),
                            const SizedBox(height: Spacing.x3),
                            Row(
                              children: <Widget>[
                                const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                DropdownButton<ComplaintStatus>(
                                  value: complaint.status,
                                  items: ComplaintStatus.values
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                                      .toList(),
                                  onChanged: (s) => s != null ? _updateStatus(s) : null,
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                const Text('Priority: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                DropdownButton<ComplaintPriority>(
                                  value: complaint.priority,
                                  items: ComplaintPriority.values
                                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                                      .toList(),
                                  onChanged: (p) => p != null ? _updatePriority(p) : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.x4),

                      // Dealer Info Card
                      if (dealer != null) ...[
                        AppCard(
                          padding: const EdgeInsets.all(Spacing.x4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Dealer Profile',
                                  style: context.textTheme.titleSmall?.copyWith(color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Text('Name: ${dealer.fullName} (${dealer.firmName})'),
                              Text('Phone: ${dealer.phone} | City: ${dealer.city}, ${dealer.state}'),
                              Text('Role: ${dealer.role.name.toUpperCase()}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: Spacing.x4),
                      ],

                      // Ticket Header Details
                      AppCard(
                        padding: const EdgeInsets.all(Spacing.x4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(complaint.subject,
                                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: Spacing.x2),
                            Text(complaint.description),
                            const Divider(height: 24),
                            Text('Category: ${complaint.category.value}'),
                            if (complaint.product != null)
                              Text('Product: ${complaint.product!.name} (${complaint.product!.productCode})'),
                            if (complaint.referenceNumber != null)
                              Text('Reference No.: ${complaint.referenceNumber}'),
                            Text('Created: ${complaint.createdAt.toLocal()}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.x4),

                      // Messages / Timeline
                      Text('Communication Timeline',
                          style: context.textTheme.titleMedium?.copyWith(color: AppColors.ink)),
                      const SizedBox(height: Spacing.x3),
                      ...complaint.messages.map((msg) => _AdminMessageBubble(message: msg)),
                    ],
                  ),
                ),
              ),

              // Owner Response Panel
              Container(
                padding: const EdgeInsets.all(Spacing.x3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _isInternal,
                          onChanged: (val) => setState(() => _isInternal = val ?? false),
                        ),
                        const Text('Internal Note (Hidden from dealer)', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: _isInternal ? 'Type internal note...' : 'Type public admin response...',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _isSending ? null : _sendMessage,
                          icon: _isSending
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.send_rounded, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminMessageBubble extends StatelessWidget {
  const _AdminMessageBubble({required this.message});

  final dynamic message;

  @override
  Widget build(BuildContext context) {
    final senderName = message.senderProfile?.fullName ?? 'User';
    final isInternal = message.isInternal as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.x3),
      padding: const EdgeInsets.all(Spacing.x3),
      decoration: BoxDecoration(
        color: isInternal ? Colors.amber.shade50 : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isInternal ? Colors.amber.shade400 : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                senderName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isInternal ? Colors.amber.shade900 : AppColors.primary,
                ),
              ),
              if (isInternal) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('INTERNAL NOTE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
              const Spacer(),
              Text(
                message.createdAt.toLocal().toString().split('.')[0],
                style: context.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: Spacing.x2),
          Text(message.message as String),
        ],
      ),
    );
  }
}
