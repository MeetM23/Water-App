import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure_presentation.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../data/repositories/supabase_complaint_repository.dart';
import '../../../../domain/enums/complaint_status.dart';
import '../../../../domain/models/complaint.dart';
import '../../application/complaint_detail_controller.dart';

/// Screen showing full details, timeline messages, attachments, and reply input for a complaint.
class ComplaintDetailScreen extends ConsumerStatefulWidget {
  /// Creates the complaint detail screen.
  const ComplaintDetailScreen({required this.complaintId, super.key});

  final String complaintId;

  @override
  ConsumerState<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends ConsumerState<ComplaintDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
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
        .sendMessage(text);

    if (!mounted) return;
    setState(() => _isSending = false);

    if (failure != null) {
      AppSnackbar.error(context, failure.title(context.l10n));
    } else {
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final complaintAsync = ref.watch(complaintDetailControllerProvider(widget.complaintId));

    return Scaffold(
      appBar: AppBar(
        title: complaintAsync.when(
          data: (c) => Text(c.ticketNumber),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
      ),
      body: complaintAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(l10n.errorGenericTitle, style: context.textTheme.titleMedium),
        ),
        data: (complaint) {
          return Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _HeaderCard(complaint: complaint),
                      const SizedBox(height: Spacing.x4),
                      if (complaint.attachments.isNotEmpty) ...[
                        _AttachmentsSection(attachments: complaint.attachments),
                        const SizedBox(height: Spacing.x4),
                      ],
                      Text(
                        l10n.complaintMessagesHeader,
                        style: context.textTheme.titleMedium?.copyWith(color: AppColors.ink),
                      ),
                      const SizedBox(height: Spacing.x3),
                      if (complaint.messages.isEmpty)
                        Text(
                          'No updates yet.',
                          style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        )
                      else
                        ...complaint.messages.map((msg) => _MessageBubble(message: msg)),
                    ],
                  ),
                ),
              ),

              // Reply Input area (if complaint is not closed)
              if (complaint.status != ComplaintStatus.closed)
                Container(
                  padding: const EdgeInsets.all(Spacing.x3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: l10n.complaintAddMessageHint,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          enabled: !_isSending,
                        ),
                      ),
                      const SizedBox(width: Spacing.x2),
                      IconButton(
                        onPressed: _isSending ? null : _sendMessage,
                        icon: _isSending
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.send_rounded, color: AppColors.primary),
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Spacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                complaint.ticketNumber,
                style: context.textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _StatusBadge(status: complaint.status),
            ],
          ),
          const SizedBox(height: Spacing.x3),
          Text(
            complaint.subject,
            style: context.textTheme.titleMedium?.copyWith(color: AppColors.ink, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: Spacing.x2),
          Text(
            complaint.description,
            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.ink),
          ),
          const Divider(height: 24),
          _DetailRow(label: 'Category', value: complaint.category.value),
          _DetailRow(label: 'Priority', value: complaint.priority.value),
          if (complaint.product != null)
            _DetailRow(label: 'Product', value: '${complaint.product!.name} (${complaint.product!.productCode})'),
          if (complaint.referenceNumber != null && complaint.referenceNumber!.isNotEmpty)
            _DetailRow(label: 'Reference No.', value: complaint.referenceNumber!),
          _DetailRow(label: 'Submitted', value: complaint.createdAt.toLocal().toString().split('.')[0]),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodySmall?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentsSection extends ConsumerWidget {
  const _AttachmentsSection({required this.attachments});

  final List<dynamic> attachments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Attachments',
          style: context.textTheme.titleSmall?.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: Spacing.x2),
        Wrap(
          spacing: 8,
          children: attachments.map((att) {
            return ActionChip(
              avatar: const Icon(Icons.image_outlined, size: 16),
              label: Text(att.fileName as String),
              onPressed: () async {
                final urlResult = await ref
                    .read(complaintRepositoryProvider)
                    .getSignedAttachmentUrl(att.storagePath as String);
                final url = urlResult.valueOrNull;
                if (url != null && context.mounted) {
                  showDialog<void>(
                    context: context,
                    builder: (_) => Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(url),
                      ),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

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
          color: isInternal ? Colors.amber.shade300 : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                senderName,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isInternal ? Colors.amber.shade900 : AppColors.primary,
                ),
              ),
              if (isInternal) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Internal Note',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
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
          Text(
            message.message as String,
            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
