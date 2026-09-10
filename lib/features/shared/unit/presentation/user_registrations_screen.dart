import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/repositories/supabase_unit_repository.dart';
import '../../../../domain/models/product_unit.dart';
import '../../../auth/application/session_controller.dart';

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
                          if (reg != null)
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
                        Text(
                          'Installation Date: ${reg.installationDate.day}/${reg.installationDate.month}/${reg.installationDate.year}',
                          style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        ),
                        Text(
                          'Warranty End: ${reg.warrantyEndDate.day}/${reg.warrantyEndDate.month}/${reg.warrantyEndDate.year}',
                          style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        ),
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
}
