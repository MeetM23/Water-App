import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/repositories/supabase_warranty_claim_repository.dart';
import '../../../../domain/models/warranty_claim.dart';
import '../../../auth/application/session_controller.dart';

/// Dealer screen displaying all warranty claims submitted by the signed-in user.
class UserWarrantyClaimsScreen extends ConsumerStatefulWidget {
  /// Creates user warranty claims screen.
  const UserWarrantyClaimsScreen({super.key});

  @override
  ConsumerState<UserWarrantyClaimsScreen> createState() =>
      _UserWarrantyClaimsScreenState();
}

class _UserWarrantyClaimsScreenState
    extends ConsumerState<UserWarrantyClaimsScreen> {
  late Future<List<WarrantyClaim>> _future;

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  void _loadClaims() {
    final session = ref.read(sessionControllerProvider).valueOrNull;
    final userId = session is SessionSignedIn ? session.profile.id : null;

    _future = ref
        .read(warrantyClaimRepositoryProvider)
        .fetchClaims(userId: userId)
        .then((res) => res.fold(
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
        title: const Text('My Warranty Claims'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => _loadClaims()),
          ),
        ],
      ),
      body: FutureBuilder<List<WarrantyClaim>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final claims = snapshot.data ?? <WarrantyClaim>[];
          if (claims.isEmpty) {
            return Center(
              child: Text(
                'No warranty claims submitted yet',
                style: context.textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(Spacing.x4),
            itemCount: claims.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
            itemBuilder: (context, index) {
              final claim = claims[index];
              final statusColor = _getStatusColor(claim.status);

              return AppCard(
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
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              claim.status.label,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.x2),
                      Text(
                        'Type: ${claim.claimType}',
                        style: context.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (claim.serialNumber != null)
                        Text(
                          'Serial: ${claim.serialNumber}',
                          style: context.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                      const SizedBox(height: Spacing.x1),
                      Text(
                        'Description: ${claim.description}',
                        style: context.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey.shade800),
                      ),
                      if (claim.adminNotes != null &&
                          claim.adminNotes!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: Spacing.x2),
                        Container(
                          padding: const EdgeInsets.all(Spacing.x2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.admin_panel_settings_outlined,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: Spacing.x1),
                              Expanded(
                                child: Text(
                                  'Admin Note: ${claim.adminNotes}',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                            'Submitted: ${claim.createdAt.day}/${claim.createdAt.month}/${claim.createdAt.year}',
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
    );
  }
}
