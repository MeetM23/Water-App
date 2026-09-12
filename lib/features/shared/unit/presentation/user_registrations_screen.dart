import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure_presentation.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/repositories/supabase_unit_repository.dart';
import '../../../../domain/models/product_unit.dart';
import '../../../auth/application/session_controller.dart';

import 'widgets/edit_registration_dialog.dart';

/// Dealer screen displaying all physical RO units registered by the signed-in user.
class UserRegistrationsScreen extends ConsumerStatefulWidget {
  /// Creates user registrations screen.
  const UserRegistrationsScreen({super.key});

  @override
  ConsumerState<UserRegistrationsScreen> createState() =>
      _UserRegistrationsScreenState();
}

class _UserRegistrationsScreenState extends ConsumerState<UserRegistrationsScreen> {
  late Future<List<ProductUnit>> _future;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  void _loadRegistrations() {
    final session = ref.read(sessionControllerProvider).valueOrNull;
    final userId = session is SessionSignedIn ? session.profile.id : null;

    _future = ref.read(unitRepositoryProvider).fetchRegistrations(userId: userId).then(
          (result) => result.fold(
            onSuccess: (units) => units,
            onFailure: (_) => <ProductUnit>[],
          ),
        );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Registered Units'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => _loadRegistrations()),
          ),
        ],
      ),
      body: FutureBuilder<List<ProductUnit>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final units = snapshot.data ?? <ProductUnit>[];
          if (units.isEmpty) {
            return Center(
              child: Text(
                'No registered units found',
                style: context.textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(Spacing.x4),
            itemCount: units.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
            itemBuilder: (context, index) {
              final unit = units[index];
              final reg = unit.registration;

              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.verified_user_outlined, color: AppColors.primary),
                          const SizedBox(width: Spacing.x2),
                          Expanded(
                            child: Text(
                              reg?.customerName ?? 'Registered Unit',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (reg != null) ...<Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: reg.isExpired ? Colors.red.shade50 : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                reg.isExpired ? 'Expired' : 'Active',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: reg.isExpired ? AppColors.danger : Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: Spacing.x1),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => _editRegistration(reg, unit),
                              tooltip: 'Edit registration',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                              onPressed: () => _deleteRegistration(reg),
                              tooltip: 'Delete registration',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: Spacing.x2),
                      Text(
                        'Product: ${unit.productName}',
                        style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Serial: ${unit.serialNumber}',
                        style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                      ),
                      if (reg != null) ...<Widget>[
                        const SizedBox(height: Spacing.x2),
                        Text(
                          'Customer Mobile: ${reg.customerPhone}',
                          style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade800),
                        ),
                        if (reg.customerCity != null)
                          Text(
                            'Location: ${reg.customerCity}',
                            style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                          ),
                        Text(
                          'Installation Date: ${reg.installationDate.day}/${reg.installationDate.month}/${reg.installationDate.year}',
                          style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        ),
                        Text(
                          'Warranty End: ${reg.warrantyEndDate.day}/${reg.warrantyEndDate.month}/${reg.warrantyEndDate.year}',
                          style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        ),
                        if (reg.sellerName != null || reg.sellerPhone != null) ...<Widget>[
                          const SizedBox(height: Spacing.x2),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(Spacing.x2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (reg.sellerName != null)
                                  Text(
                                    'Retailer/Wholesaler: ${reg.sellerName}',
                                    style: context.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                if (reg.sellerPhone != null)
                                  Text(
                                    'Retailer Contact: ${reg.sellerPhone}',
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: AppColors.ink,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
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

  Future<void> _editRegistration(UnitRegistrationInfo reg, ProductUnit unit) async {
    final result = await EditRegistrationDialog.show(context, reg);

    if (result != null && mounted) {
      await ref.read(unitRepositoryProvider).updateRegistration(
        registrationId: reg.id,
        customerName: result['customerName']!,
        customerPhone: result['customerPhone']!,
        customerCity: result['customerCity'],
        customerAddress: result['customerAddress'],
        invoiceNumber: result['invoiceNumber'],
        sellerName: result['sellerName'],
        sellerPhone: result['sellerPhone'],
      );

      if (mounted) {
        setState(() {
          _loadRegistrations();
        });
      }
    }
  }

  Future<void> _deleteRegistration(UnitRegistrationInfo reg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Registration'),
        content: Text('Are you sure you want to delete registration for "${reg.customerName}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final res = await ref.read(unitRepositoryProvider).deleteRegistration(reg.id);
      if (mounted) {
        res.fold(
          onSuccess: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration deleted successfully')),
            );
          },
          onFailure: (err) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not delete registration: ${err.title(context.l10n)}')),
            );
          },
        );
        setState(() {
          _loadRegistrations();
        });
      }
    }
  }
}
