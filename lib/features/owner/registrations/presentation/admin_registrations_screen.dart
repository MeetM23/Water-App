import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/repositories/supabase_unit_repository.dart';
import '../../../../domain/models/product_unit.dart';

/// Admin/Owner screen to view and search all registered physical RO units.
class AdminRegistrationsScreen extends ConsumerStatefulWidget {
  /// Creates admin registrations screen.
  const AdminRegistrationsScreen({super.key});

  @override
  ConsumerState<AdminRegistrationsScreen> createState() =>
      _AdminRegistrationsScreenState();
}

class _AdminRegistrationsScreenState
    extends ConsumerState<AdminRegistrationsScreen> {
  String _searchQuery = '';
  late Future<List<ProductUnit>> _future;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  void _loadRegistrations() {
    _future = ref.read(unitRepositoryProvider).fetchRegistrations().then(
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
        title: const Text('Product Registrations'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _loadRegistrations();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(Spacing.x4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by customer, phone, or serial number...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ProductUnit>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load registrations: ${snapshot.error}'),
                  );
                }

                final units = snapshot.data ?? <ProductUnit>[];
                final filtered = units.where((unit) {
                  if (_searchQuery.isEmpty) return true;
                  final reg = unit.registration;
                  final matchName = reg?.customerName.toLowerCase().contains(_searchQuery) ?? false;
                  final matchPhone = reg?.customerPhone.toLowerCase().contains(_searchQuery) ?? false;
                  final matchSerial = unit.serialNumber.toLowerCase().contains(_searchQuery);
                  final matchProduct = unit.productName.toLowerCase().contains(_searchQuery);
                  return matchName || matchPhone || matchSerial || matchProduct;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No product registrations found'
                          : 'No matching registrations',
                      style: context.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(Spacing.x4),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Spacing.x3),
                  itemBuilder: (context, index) {
                    final unit = filtered[index];
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
                                    reg?.customerName ?? 'Customer',
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
                                'Mobile: ${reg.customerPhone}',
                                style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade800),
                              ),
                              if (reg.customerCity != null)
                                Text(
                                  'Location: ${reg.customerCity}',
                                  style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                                ),
                              Text(
                                'Installation: ${reg.installationDate.day}/${reg.installationDate.month}/${reg.installationDate.year}',
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
          ),
        ],
      ),
    );
  }
}
