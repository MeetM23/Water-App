import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/errors/failure_presentation.dart';
import '../../../../data/repositories/supabase_warranty_claim_repository.dart';
import '../../../../domain/models/warranty_claim.dart';


/// Admin/Owner detail screen for inspecting and updating a warranty claim ticket.
class AdminWarrantyClaimDetailScreen extends ConsumerStatefulWidget {
  /// Creates admin warranty claim detail screen.
  const AdminWarrantyClaimDetailScreen({
    super.key,
    required this.claimId,
  });

  /// The UUID of the claim.
  final String claimId;

  @override
  ConsumerState<AdminWarrantyClaimDetailScreen> createState() =>
      _AdminWarrantyClaimDetailScreenState();
}

class _AdminWarrantyClaimDetailScreenState
    extends ConsumerState<AdminWarrantyClaimDetailScreen> {
  late Future<WarrantyClaim?> _future;
  WarrantyClaimStatus _currentStatus = WarrantyClaimStatus.pending;
  final _adminNotesController = TextEditingController();
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadClaim();
  }

  @override
  void dispose() {
    _adminNotesController.dispose();
    super.dispose();
  }

  void _loadClaim() {
    _future = ref
        .read(warrantyClaimRepositoryProvider)
        .fetchClaimById(widget.claimId)
        .then((res) => res.fold(
              onSuccess: (claim) {
                if (claim != null && !_isInitialized) {
                  _currentStatus = claim.status;
                  _adminNotesController.text = claim.adminNotes ?? '';
                  _isInitialized = true;
                }
                return claim;
              },
              onFailure: (_) => null,
            ));
  }

  Future<void> _saveStatus(WarrantyClaim claim) async {
    setState(() => _isSaving = true);

    final repository = ref.read(warrantyClaimRepositoryProvider);
    final result = await repository.updateClaimStatus(
      claimId: claim.id,
      status: _currentStatus,
      adminNotes: _adminNotesController.text.trim().isEmpty
          ? null
          : _adminNotesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      onSuccess: (_) {
        AppSnackbar.success(
          context,
          'Claim ${claim.claimNumber} updated to ${_currentStatus.label}!',
        );
        setState(() {
          _isInitialized = false;
          _loadClaim();
        });
      },
      onFailure: (failure) {
        AppSnackbar.error(
          context,
          'Failed to update claim status: ${failure.message(context.l10n)}',
        );
      },
    );
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
        title: const Text('Claim Details'),
      ),
      body: FutureBuilder<WarrantyClaim?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final claim = snapshot.data;
          if (claim == null) {
            return const Center(child: Text('Claim not found'));
          }

          final statusColor = _getStatusColor(claim.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header Card
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.x4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              claim.claimNumber,
                              style: context.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                claim.status.label,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.x2),
                        Text(
                          'Submitted: ${claim.createdAt.day}/${claim.createdAt.month}/${claim.createdAt.year}',
                          style: context.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.x4),

                // Physical Unit Information Card
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.x4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(Icons.water_drop_outlined,
                                color: AppColors.primary),
                            const SizedBox(width: Spacing.x2),
                            Text(
                              'Physical Machine Unit',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.x3),
                        Text(
                          'Product: ${claim.productName ?? "Maruti RO Purifier"}',
                          style: context.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Model: ${claim.modelNumber ?? "Standard"}',
                          style: context.textTheme.bodyMedium,
                        ),
                        Text(
                          'Serial: ${claim.serialNumber ?? "N/A"}',
                          style: context.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.x4),

                // Claimant & Contact Card
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.x4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(Icons.person_outline,
                                color: AppColors.primary),
                            const SizedBox(width: Spacing.x2),
                            Text(
                              'Claimant Details',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.x3),
                        Text(
                          'Name: ${claim.userFullName ?? "Dealer User"}',
                          style: context.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (claim.userCompany != null)
                          Text(
                            'Company: ${claim.userCompany}',
                            style: context.textTheme.bodyMedium,
                          ),
                        Text(
                          'Contact Phone: ${claim.contactPhone}',
                          style: context.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.x4),

                // Issue Description Card
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.x4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(Icons.description_outlined,
                                color: AppColors.primary),
                            const SizedBox(width: Spacing.x2),
                            Text(
                              'Claim Issue Details',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.x3),
                        Text(
                          'Type: ${claim.claimType}',
                          style: context.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: Spacing.x2),
                        Text(
                          claim.description,
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.x4),

                Container(
                  padding: const EdgeInsets.all(Spacing.x4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                        Row(
                          children: <Widget>[
                            const Icon(Icons.admin_panel_settings_outlined,
                                color: AppColors.primary),
                            const SizedBox(width: Spacing.x2),
                            Text(
                              'Admin Status Management',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.x3),
                        DropdownButtonFormField<WarrantyClaimStatus>(
                          value: _currentStatus,
                          decoration: const InputDecoration(
                            labelText: 'Update Claim Status',
                            prefixIcon: Icon(Icons.change_circle_outlined),
                          ),
                          items: WarrantyClaimStatus.values.map((status) {
                            return DropdownMenuItem<WarrantyClaimStatus>(
                              value: status,
                              child: Text(status.label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _currentStatus = value);
                            }
                          },
                        ),
                        const SizedBox(height: Spacing.x3),
                        TextFormField(
                          controller: _adminNotesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Admin Notes / Inspection Resolution',
                            hintText: 'Add notes for the dealer...',
                            prefixIcon: Icon(Icons.note_alt_outlined),
                          ),
                        ),
                        const SizedBox(height: Spacing.x4),
                        AppButton(
                          label: 'Save Status Update',
                          isLoading: _isSaving,
                          onPressed: _isSaving ? null : () => _saveStatus(claim),
                        ),
                      ],
                    ),
                ),
              ],


            ),
          );
        },
      ),
    );
  }
}
