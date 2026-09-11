import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../data/repositories/supabase_warranty_claim_repository.dart';
import '../../../../domain/models/warranty_claim.dart';

/// Admin/Owner screen to manage submitted Warranty & Claim requests.
class AdminWarrantyClaimsScreen extends ConsumerStatefulWidget {
  /// Creates admin warranty claims screen.
  const AdminWarrantyClaimsScreen({super.key});

  @override
  ConsumerState<AdminWarrantyClaimsScreen> createState() =>
      _AdminWarrantyClaimsScreenState();
}

class _AdminWarrantyClaimsScreenState
    extends ConsumerState<AdminWarrantyClaimsScreen> {
  WarrantyClaimStatus? _selectedStatusFilter;
  late Future<List<WarrantyClaim>> _future;

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  void _loadClaims() {
    _future = ref.read(warrantyClaimRepositoryProvider).fetchClaims(
          status: _selectedStatusFilter,
        ).then((res) => res.fold(
              onSuccess: (claims) => claims,
              onFailure: (_) => <WarrantyClaim>[],
            ));
  }


  Color _getStatusColor(WarrantyClaimStatus status) {
    return switch (status) {
      WarrantyClaimStatus.pending => Colors.orange,
      WarrantyClaimStatus.approved => Colors.green,
      WarrantyClaimStatus.rejected => AppColors.danger,
      WarrantyClaimStatus.resolved => Colors.blue,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warranty Claims Management'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _loadClaims();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.x4, vertical: Spacing.x2),
            child: Row(
              children: <Widget>[
                FilterChip(
                  label: Text(
                    'All',
                    style: TextStyle(
                      color: _selectedStatusFilter == null
                          ? Colors.white
                          : AppColors.primaryDark,
                      fontWeight: _selectedStatusFilter == null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: _selectedStatusFilter == null,
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatusFilter = null;
                        _loadClaims();
                      });
                    }
                  },
                ),
                const SizedBox(width: Spacing.x2),
                ...WarrantyClaimStatus.values.map((status) {
                  final isSelected = _selectedStatusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: Spacing.x2),
                    child: FilterChip(
                      label: Text(
                        status.label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.primaryDark,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatusFilter = selected ? status : null;
                          _loadClaims();
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<WarrantyClaim>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading claims: ${snapshot.error}'),
                  );
                }

                final claims = snapshot.data ?? <WarrantyClaim>[];
                if (claims.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.build_circle_outlined,
                    title: 'No Warranty Claims Found',
                    message: _selectedStatusFilter == null
                        ? 'Submitted warranty claim requests from dealers and customers will appear here.'
                        : 'No claims found with status "${_selectedStatusFilter!.label}".',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(Spacing.x4),
                  itemCount: claims.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
                  itemBuilder: (context, index) {
                    final claim = claims[index];
                    final color = _getStatusColor(claim.status);

                    return AppCard(
                      onTap: () async {
                        await context.push(AppRoutes.ownerClaimDetail(claim.id));
                        setState(() {
                          _loadClaims();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.x4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  claim.claimNumber,
                                  style: context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    claim.status.label,
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Spacing.x2),
                            Text(
                              'Type: ${claim.claimType}',
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (claim.serialNumber != null)
                              Text(
                                'Serial: ${claim.serialNumber}',
                                style: context.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade700),
                              ),
                            if (claim.userFullName != null)
                              Text(
                                'Dealer: ${claim.userFullName} (${claim.userCompany ?? "N/A"})',
                                style: context.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade800),
                              ),
                            const SizedBox(height: Spacing.x1),
                            Text(
                              'Description: ${claim.description}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: Spacing.x2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Phone: ${claim.contactPhone}',
                                  style: context.textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                                Text(
                                  '${claim.createdAt.day}/${claim.createdAt.month}/${claim.createdAt.year}',
                                  style: context.textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
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
}
