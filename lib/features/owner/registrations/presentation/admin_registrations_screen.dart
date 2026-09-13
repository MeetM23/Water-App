import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../data/repositories/supabase_unit_repository.dart';
import '../../../../domain/enums/product_category.dart';
import '../../../../domain/models/product_unit.dart';
import '../../../shared/unit/presentation/widgets/edit_registration_dialog.dart';

/// Admin/Owner screen to view and search all registered physical RO units.
///
/// Products are grouped by [ProductCategory] so the admin can quickly scan
/// how many Domestic, Commercial, Industrial, etc. units have been registered.
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

  /// Which category sections are currently expanded (all open by default).
  final Set<ProductCategory> _expandedCategories = <ProductCategory>{
    ProductCategory.domestic,
    ProductCategory.commercial,
    ProductCategory.industrial,
    ProductCategory.sparePart,
    ProductCategory.accessory,
  };

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

  /// Human-readable label for each category (admin screen — English only).
  static String _categoryLabel(ProductCategory cat) => switch (cat) {
        ProductCategory.domestic => 'Domestic',
        ProductCategory.commercial => 'Commercial',
        ProductCategory.industrial => 'Industrial',
        ProductCategory.sparePart => 'Spare Parts',
        ProductCategory.accessory => 'Accessories',
      };

  /// Icon for each category section header.
  static IconData _categoryIcon(ProductCategory cat) => switch (cat) {
        ProductCategory.domestic => Icons.home_rounded,
        ProductCategory.commercial => Icons.store_rounded,
        ProductCategory.industrial => Icons.factory_rounded,
        ProductCategory.sparePart => Icons.build_rounded,
        ProductCategory.accessory => Icons.extension_rounded,
      };

  /// Groups [units] by category, preserving [ProductCategory.values] order.
  /// Only categories that have at least one unit are included.
  Map<ProductCategory, List<ProductUnit>> _groupByCategory(
      List<ProductUnit> units) {
    final map = <ProductCategory, List<ProductUnit>>{};
    for (final cat in ProductCategory.values) {
      final items = units.where((u) => u.category == cat).toList();
      if (items.isNotEmpty) map[cat] = items;
    }
    return map;
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
                    child: Text(
                        'Failed to load registrations: ${snapshot.error}'),
                  );
                }

                final units = snapshot.data ?? <ProductUnit>[];

                // Apply search filter.
                final filtered = units.where((unit) {
                  if (_searchQuery.isEmpty) return true;
                  final reg = unit.registration;
                  final matchName = reg?.customerName
                          ?.toLowerCase()
                          .contains(_searchQuery) ??
                      false;
                  final matchPhone = reg?.customerPhone
                          ?.toLowerCase()
                          .contains(_searchQuery) ??
                      false;
                  final matchSerial =
                      unit.serialNumber.toLowerCase().contains(_searchQuery);
                  final matchProduct =
                      unit.productName.toLowerCase().contains(_searchQuery);
                  final matchSeller =
                      (reg?.sellerName?.toLowerCase().contains(_searchQuery) ??
                              false) ||
                          (reg?.sellerPhone
                                  ?.toLowerCase()
                                  .contains(_searchQuery) ??
                              false);
                  return matchName ||
                      matchPhone ||
                      matchSerial ||
                      matchProduct ||
                      matchSeller;
                }).toList();

                if (filtered.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.assignment_turned_in_outlined,
                    title: _searchQuery.isEmpty
                        ? 'No Product Registrations Found'
                        : 'No Matching Registrations',
                    message: _searchQuery.isEmpty
                        ? 'Registered machine units will appear here once dealers submit customer installation records.'
                        : 'No registration records match your search "$_searchQuery".',
                  );
                }

                // Group by category and render sections.
                final grouped = _groupByCategory(filtered);

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.x4, 0, Spacing.x4, Spacing.x8),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, sectionIndex) {
                    final category = grouped.keys.elementAt(sectionIndex);
                    final categoryUnits = grouped[category]!;
                    final isExpanded = _expandedCategories.contains(category);

                    return Padding(
                      padding: const EdgeInsets.only(top: Spacing.x3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Section header (tap to expand/collapse).
                          _CategorySectionHeader(
                            category: category,
                            label: _categoryLabel(category),
                            icon: _categoryIcon(category),
                            count: categoryUnits.length,
                            isExpanded: isExpanded,
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedCategories.remove(category);
                                } else {
                                  _expandedCategories.add(category);
                                }
                              });
                            },
                          ),
                          // Cards inside the section.
                          if (isExpanded) ...<Widget>[
                            const SizedBox(height: Spacing.x2),
                            ...categoryUnits.map((unit) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: Spacing.x3),
                                child: _RegistrationCard(
                                  unit: unit,
                                  onEdit: (reg) =>
                                      _editRegistration(reg, unit),
                                  onDelete: _deleteRegistration,
                                ),
                              );
                            }),
                          ],
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

  Future<void> _editRegistration(
      UnitRegistrationInfo reg, ProductUnit unit) async {
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
        content: Text(
            'Are you sure you want to delete registration for "${reg.customerName}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(unitRepositoryProvider).deleteRegistration(reg.id);
      if (mounted) {
        setState(() {
          _loadRegistrations();
        });
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header Widget
// ─────────────────────────────────────────────────────────────────────────────

class _CategorySectionHeader extends StatelessWidget {
  const _CategorySectionHeader({
    required this.category,
    required this.label,
    required this.icon,
    required this.count,
    required this.isExpanded,
    required this.onTap,
  });

  final ProductCategory category;
  final String label;
  final IconData icon;
  final int count;
  final bool isExpanded;
  final VoidCallback onTap;

  /// Distinct accent colour per category for easy visual scanning.
  Color get _accentColor => switch (category) {
        ProductCategory.domestic => const Color(0xFF1565C0),   // deep blue
        ProductCategory.commercial => const Color(0xFF2E7D32), // green
        ProductCategory.industrial => const Color(0xFFE65100), // deep orange
        ProductCategory.sparePart => const Color(0xFF6A1B9A),  // purple
        ProductCategory.accessory => const Color(0xFF00838F),  // teal
      };

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.x4, vertical: Spacing.x3),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.25)),
        ),
        child: Row(
          children: <Widget>[
            // Category icon badge.
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: Spacing.x3),
            // Category label.
            Expanded(
              child: Text(
                label,
                style: context.textTheme.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Count badge.
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: context.textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: Spacing.x2),
            // Animated chevron.
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child:
                  Icon(Icons.expand_more_rounded, color: accent, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Registration Card Widget
// ─────────────────────────────────────────────────────────────────────────────

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({
    required this.unit,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductUnit unit;
  final void Function(UnitRegistrationInfo) onEdit;
  final void Function(UnitRegistrationInfo) onDelete;

  @override
  Widget build(BuildContext context) {
    final reg = unit.registration;

    return AppCard(
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
                Expanded(
                  child: Text(
                    unit.productName,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (reg != null) ...<Widget>[
                  // Active / Expired badge.
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: reg.isExpired
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reg.isExpired ? 'Expired' : 'Active',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: reg.isExpired
                            ? AppColors.danger
                            : Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.x1),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => onEdit(reg),
                    tooltip: 'Edit registration',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.danger),
                    onPressed: () => onDelete(reg),
                    tooltip: 'Delete registration',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ],
            ),
            const SizedBox(height: Spacing.x1),
            Row(
              children: <Widget>[
                Text(
                  'Serial: ${unit.serialNumber}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (reg != null) ...<Widget>[
              const SizedBox(height: Spacing.x2),
              const Divider(height: 1),
              const SizedBox(height: Spacing.x2),
              Text(
                'Customer: ${reg.customerName ?? 'N/A'}',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Mobile: ${reg.customerPhone ?? 'N/A'}',
                style: context.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade800),
              ),
              if (reg.customerCity != null && reg.customerCity!.isNotEmpty)
                Text(
                  'Location: ${reg.customerCity}',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey.shade700),
                ),
              Text(
                'Installation: ${reg.installationDate.day}/${reg.installationDate.month}/${reg.installationDate.year}',
                style: context.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              Text(
                'Warranty End: ${reg.warrantyEndDate.day}/${reg.warrantyEndDate.month}/${reg.warrantyEndDate.year}',
                style: context.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              // Seller info box.
              if (reg.sellerName != null ||
                  reg.sellerPhone != null) ...<Widget>[
                const SizedBox(height: Spacing.x2),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Spacing.x2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.2)),
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
  }
}
