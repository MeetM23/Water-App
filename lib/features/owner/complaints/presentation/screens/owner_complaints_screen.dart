import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:maruti_water/core/extensions/build_context_x.dart';
import 'package:maruti_water/core/router/app_routes.dart';
import 'package:maruti_water/core/theme/app_colors.dart';
import 'package:maruti_water/core/theme/app_spacing.dart';
import 'package:maruti_water/core/widgets/app_card.dart';
import 'package:maruti_water/domain/enums/complaint_category.dart';
import 'package:maruti_water/domain/enums/complaint_priority.dart';
import 'package:maruti_water/domain/enums/complaint_status.dart';
import '../../application/owner_complaints_controller.dart';

/// Owner dashboard screen for viewing and filtering all dealer complaints.
class OwnerComplaintsScreen extends ConsumerStatefulWidget {
  /// Creates the owner complaints screen.
  const OwnerComplaintsScreen({super.key});

  @override
  ConsumerState<OwnerComplaintsScreen> createState() => _OwnerComplaintsScreenState();
}

class _OwnerComplaintsScreenState extends ConsumerState<OwnerComplaintsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final complaintsAsync = ref.watch(ownerComplaintsControllerProvider);
    final filter = ref.watch(ownerComplaintQueryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ownerComplaintsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(ownerComplaintsControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(Spacing.x4),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by ticket #, dealer, or subject...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(ownerComplaintQueryControllerProvider.notifier)
                                  .setSearchQuery('');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    ref
                        .read(ownerComplaintQueryControllerProvider.notifier)
                        .setSearchQuery(val);
                  },
                ),
                const SizedBox(height: Spacing.x3),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      // Status filter
                      DropdownButton<ComplaintStatus?>(
                        value: filter.status,
                        hint: const Text('Status: All'),
                        items: [
                          const DropdownMenuItem<ComplaintStatus?>(
                            value: null,
                            child: Text('Status: All'),
                          ),
                          ...ComplaintStatus.values.map(
                            (s) => DropdownMenuItem<ComplaintStatus?>(
                              value: s,
                              child: Text(s.name),
                            ),
                          ),
                        ],
                        onChanged: (val) => ref
                            .read(ownerComplaintQueryControllerProvider.notifier)
                            .setStatus(val),
                      ),
                      const SizedBox(width: 12),

                      // Priority filter
                      DropdownButton<ComplaintPriority?>(
                        value: filter.priority,
                        hint: const Text('Priority: All'),
                        items: [
                          const DropdownMenuItem<ComplaintPriority?>(
                            value: null,
                            child: Text('Priority: All'),
                          ),
                          ...ComplaintPriority.values.map(
                            (p) => DropdownMenuItem<ComplaintPriority?>(
                              value: p,
                              child: Text(p.name),
                            ),
                          ),
                        ],
                        onChanged: (val) => ref
                            .read(ownerComplaintQueryControllerProvider.notifier)
                            .setPriority(val),
                      ),
                      const SizedBox(width: 12),

                      // Category filter
                      DropdownButton<ComplaintCategory?>(
                        value: filter.category,
                        hint: const Text('Category: All'),
                        items: [
                          const DropdownMenuItem<ComplaintCategory?>(
                            value: null,
                            child: Text('Category: All'),
                          ),
                          ...ComplaintCategory.values.map(
                            (c) => DropdownMenuItem<ComplaintCategory?>(
                              value: c,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (val) => ref
                            .read(ownerComplaintQueryControllerProvider.notifier)
                            .setCategory(val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: complaintsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Failed to load complaints', style: context.textTheme.titleMedium),
              ),
              data: (complaints) {
                if (complaints.isEmpty) {
                  return const Center(child: Text('No complaints match current filters.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.x4, vertical: Spacing.x2),
                  itemCount: complaints.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    final dealer = complaint.userProfile;

                    return AppCard(
                      onTap: () => context.push(AppRoutes.ownerComplaintDetailPath(complaint.id)),
                      padding: const EdgeInsets.all(Spacing.x4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                complaint.ticketNumber,
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (dealer != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    dealer.role.name.toUpperCase(),
                                    style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              const Spacer(),
                              Text(
                                complaint.status.name.toUpperCase(),
                                style: TextStyle(
                                  color: _statusColor(complaint.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.x2),
                          Text(
                            complaint.subject,
                            style: context.textTheme.titleMedium?.copyWith(color: AppColors.ink),
                          ),
                          if (dealer != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Dealer: ${dealer.fullName} (${dealer.firmName}) • ${dealer.phone}',
                              style: context.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                          const SizedBox(height: Spacing.x2),
                          Row(
                            children: <Widget>[
                              Text(
                                'Priority: ${complaint.priority.name}',
                                style: context.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                              ),
                              const Spacer(),
                              Text(
                                complaint.createdAt.toLocal().toString().split(' ')[0],
                                style: context.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(ComplaintStatus status) => switch (status) {
        ComplaintStatus.open => AppColors.primary,
        ComplaintStatus.inProgress => Colors.amber.shade800,
        ComplaintStatus.resolved => Colors.green.shade700,
        ComplaintStatus.closed => AppColors.textSecondary,
      };
}
