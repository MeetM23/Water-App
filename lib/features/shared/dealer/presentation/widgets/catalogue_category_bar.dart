import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/enums/product_category.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../auth/application/session_controller.dart';
import '../../application/catalogue_controller.dart';
import 'catalogue_filter_sheet.dart';

/// Horizontal options bar placed right below the banner carousel.
///
/// Features direct visual filter tabs for:
/// - All
/// - Domestic
/// - Commercial
/// - Industrial
/// - Accessories
/// - Service
class CatalogueCategoryBar extends ConsumerWidget {
  /// Creates the horizontal category bar.
  const CatalogueCategoryBar({
    required this.onResetFilters,
    super.key,
  });

  /// Callback when clearing active filters.
  final VoidCallback onResetFilters;

  void _openServiceOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(
            Spacing.x5,
            Spacing.x4,
            Spacing.x5,
            Spacing.x6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Sheet Header handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: Spacing.x4),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(Spacing.x2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: Spacing.x3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Service & Support',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Book service, claim warranty or contact support',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.x4),
              const Divider(color: AppColors.border),
              const SizedBox(height: Spacing.x2),

              // Service Option 1: Book Service / Complaint
              _ServiceActionTile(
                icon: Icons.handyman_rounded,
                title: 'Book Machine Service / Repair',
                subtitle: 'Register a complaint or request technical maintenance',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  final session = ref.read(sessionControllerProvider).valueOrNull;
                  if (session is SessionSignedIn &&
                      session.profile.role == UserRole.owner) {
                    context.push(AppRoutes.ownerComplaints);
                  } else if (session is SessionSignedIn) {
                    context.push(AppRoutes.complaints);
                  } else {
                    context.push(
                      '${AppRoutes.login}?from=${Uri.encodeComponent(AppRoutes.complaints)}',
                    );
                  }
                },
              ),

              // Service Option 2: Register Warranty
              _ServiceActionTile(
                icon: Icons.verified_rounded,
                title: 'Register Product Warranty',
                subtitle: 'Register a physical unit serial number to activate warranty',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(AppRoutes.productRegistration);
                },
              ),

              // Service Option 3: Claim Warranty
              _ServiceActionTile(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Submit Warranty Claim',
                subtitle: 'Request replacement or service for a registered machine',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(AppRoutes.warrantyClaim);
                },
              ),

              // Service Option 4: Direct Helpline
              _ServiceActionTile(
                icon: Icons.phone_in_talk_rounded,
                title: 'Call Helpline Support',
                subtitle: 'Talk directly with Maruti Water Solution team',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showCallSupportDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCallSupportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: <Widget>[
              Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
              SizedBox(width: Spacing.x2),
              Text('Customer Care'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Maruti Water Solution Support Helpline',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: Spacing.x2),
              Text(
                'For service inquiries, parts, or general assistance, contact us at:',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: Spacing.x3),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.x3),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.call_rounded, color: AppColors.primary),
                    const SizedBox(width: Spacing.x3),
                    SelectableText(
                      '+91 98765 43210',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(catalogueQueryControllerProvider);
    final controller = ref.read(catalogueQueryControllerProvider.notifier);

    // Definitions of the horizontal options
    final List<_CategoryTabItem> tabs = <_CategoryTabItem>[
      _CategoryTabItem(
        label: 'All',
        icon: Icons.grid_view_rounded,
        isSelected: query.category == null,
        onTap: () => controller.setCategory(null),
      ),
      _CategoryTabItem(
        label: 'Domestic',
        icon: Icons.home_rounded,
        isSelected: query.category == ProductCategory.domestic,
        onTap: () => controller.setCategory(ProductCategory.domestic),
      ),
      _CategoryTabItem(
        label: 'Commercial',
        icon: Icons.business_rounded,
        isSelected: query.category == ProductCategory.commercial,
        onTap: () => controller.setCategory(ProductCategory.commercial),
      ),
      _CategoryTabItem(
        label: 'Industrial',
        icon: Icons.factory_rounded,
        isSelected: query.category == ProductCategory.industrial,
        onTap: () => controller.setCategory(ProductCategory.industrial),
      ),
      _CategoryTabItem(
        label: 'Accessories',
        icon: Icons.build_rounded,
        isSelected: query.category == ProductCategory.accessory,
        onTap: () => controller.setCategory(ProductCategory.accessory),
      ),
      _CategoryTabItem(
        label: 'Service',
        icon: Icons.headset_mic_rounded,
        isSelected: false,
        isService: true,
        onTap: () => _openServiceOptions(context, ref),
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Spacing.x2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Horizontal Options Bar with clean Segmented Styling
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: Spacing.x4),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < tabs.length; i++) ...<Widget>[
                    _CategoryOptionTile(tab: tabs[i]),
                    if (i < tabs.length - 1)
                      Container(
                        height: 20,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        color: AppColors.border.withOpacity(0.6),
                      ),
                  ],

                  // Sort Button (compact icon button at the end)
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => CatalogueFilterSheet.show(
                      context,
                      onReset: onResetFilters,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.x2,
                        vertical: Spacing.x2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: <Widget>[
                          Icon(
                            Icons.swap_vert_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Sort',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabItem {
  const _CategoryTabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isService = false,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isService;
}

class _CategoryOptionTile extends StatelessWidget {
  const _CategoryOptionTile({required this.tab});

  final _CategoryTabItem tab;

  @override
  Widget build(BuildContext context) {
    final isSelected = tab.isSelected;
    final isService = tab.isService;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tab.onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.x3,
            vertical: Spacing.x2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isService
                    ? AppColors.primaryTint.withOpacity(0.5)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                tab.icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isService ? AppColors.primary : AppColors.primary),
              ),
              const SizedBox(width: Spacing.x2),
              Text(
                tab.label,
                style: context.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isService ? AppColors.primary : AppColors.ink),
                  fontWeight: (isSelected || isService)
                      ? FontWeight.bold
                      : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceActionTile extends StatelessWidget {
  const _ServiceActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.x2),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(Spacing.x3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(Spacing.x3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: Spacing.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
