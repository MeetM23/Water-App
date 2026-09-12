import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/build_context_x.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/contact_launcher.dart';
import '../../../../../domain/enums/product_category.dart';
import '../../../../auth/application/session_controller.dart';
import '../../application/catalogue_controller.dart';

/// Fixed full-width options bar placed right below the banner carousel.
///
/// Features 3 equal-width fixed segmented buttons divided by vertical borders:
/// 1. "Sort" dropdown (Name A-Z, Price Low to High, Price High to Low)
/// 2. "Category" dropdown (All categories, Domestic, Commercial, Industrial, Accessories)
/// 3. "Customer Service" action button (opens support WhatsApp modal)
class CatalogueCategoryBar extends ConsumerWidget {
  /// Creates the fixed segmented category bar.
  const CatalogueCategoryBar({
    this.onResetFilters,
    super.key,
  });

  /// Callback when clearing active filters.
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(catalogueQueryControllerProvider);
    final controller = ref.read(catalogueQueryControllerProvider.notifier);

    final String categoryLabel = switch (query.category) {
      null => 'Category',
      ProductCategory.domestic => l10n.categoryDomestic,
      ProductCategory.commercial => l10n.categoryCommercial,
      ProductCategory.industrial => l10n.categoryIndustrial,
      ProductCategory.accessory => l10n.categoryAccessory,
      ProductCategory.sparePart => l10n.categorySparePart,
    };

    final String sortLabel = switch (query.sort) {
      CatalogueSort.name => 'Sort',
      CatalogueSort.priceAscending => 'Low-High',
      CatalogueSort.priceDescending => 'High-Low',
    };

    final bool isSortActive = query.sort != CatalogueSort.name;
    final bool isCategoryActive = query.category != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        Spacing.x4,
        Spacing.x2,
        Spacing.x4,
        Spacing.x2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Sort Dropdown (Segment 1)
            Expanded(
              child: _FixedSegmentButton<CatalogueSort>(
                label: sortLabel,
                leadingIcon: Icons.swap_vert_rounded,
                isActive: isSortActive,
                selectedValue: query.sort,
                onSelected: (CatalogueSort sort) => controller.setSort(sort),
                items: <PopupMenuEntry<CatalogueSort>>[
                  PopupMenuItem<CatalogueSort>(
                    value: CatalogueSort.name,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.sort_by_alpha_rounded,
                          size: 18,
                          color: query.sort == CatalogueSort.name
                              ? AppColors.primary
                              : AppColors.ink,
                        ),
                        const SizedBox(width: Spacing.x2),
                        Text(
                          'Name (A to Z)',
                          style: TextStyle(
                            fontWeight: query.sort == CatalogueSort.name
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: query.sort == CatalogueSort.name
                                ? AppColors.primary
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<CatalogueSort>(
                    value: CatalogueSort.priceAscending,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 18,
                          color: query.sort == CatalogueSort.priceAscending
                              ? AppColors.primary
                              : AppColors.ink,
                        ),
                        const SizedBox(width: Spacing.x2),
                        Text(
                          'Price: Low to High',
                          style: TextStyle(
                            fontWeight: query.sort == CatalogueSort.priceAscending
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: query.sort == CatalogueSort.priceAscending
                                ? AppColors.primary
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<CatalogueSort>(
                    value: CatalogueSort.priceDescending,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 18,
                          color: query.sort == CatalogueSort.priceDescending
                              ? AppColors.primary
                              : AppColors.ink,
                        ),
                        const SizedBox(width: Spacing.x2),
                        Text(
                          'Price: High to Low',
                          style: TextStyle(
                            fontWeight: query.sort == CatalogueSort.priceDescending
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: query.sort == CatalogueSort.priceDescending
                                ? AppColors.primary
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Vertical Border Divider 1
            Container(
              width: 1,
              color: AppColors.border,
            ),

            // 2. Category Dropdown (Segment 2)
            Expanded(
              child: _FixedSegmentButton<String>(
                label: categoryLabel,
                trailingIcon: Icons.keyboard_arrow_down_rounded,
                isActive: isCategoryActive,
                selectedValue: query.category?.name ?? 'all',
                onSelected: (String value) {
                  if (value == 'all') {
                    controller.reset();
                    if (onResetFilters != null) {
                      onResetFilters!();
                    }
                  } else {
                    final category = ProductCategory.values.firstWhere(
                      (c) => c.name == value,
                      orElse: () => ProductCategory.domestic,
                    );
                    controller.setCategory(category);
                  }
                },
                items: <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'all',
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.grid_view_rounded,
                          size: 18,
                          color: query.category == null
                              ? AppColors.primary
                              : AppColors.ink,
                        ),
                        const SizedBox(width: Spacing.x2),
                        Text(
                          'All Categories',
                          style: TextStyle(
                            fontWeight: query.category == null
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: query.category == null
                                ? AppColors.primary
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: ProductCategory.domestic.name,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.home_rounded,
                          size: 18,
                          color: query.category == ProductCategory.domestic
                              ? AppColors.primary
                              : AppColors.ink,
                        ),
                        const SizedBox(width: Spacing.x2),
                        Text(
                          l10n.categoryDomestic,
                          style: TextStyle(
                            fontWeight: query.category == ProductCategory.domestic
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: query.category == ProductCategory.domestic
                                ? AppColors.primary
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: ProductCategory.commercial.name,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.business_rounded,
                          size: 18,
                          color: query.category == ProductCategory.commercial
                              ? AppColors.primary
                              : AppColors.ink,
                        ),
                        const SizedBox(width: Spacing.x2),
                        Text(
                          l10n.categoryCommercial,
                          style: TextStyle(
                            fontWeight: query.category == ProductCategory.commercial
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: query.category == ProductCategory.commercial
                                ? AppColors.primary
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: ProductCategory.industrial.name,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.factory_rounded,
                          size: 18,
                          color: query.category == ProductCategory.industrial
                              ? AppColors.primary
                              : AppColors.ink,
                        ),
                        const SizedBox(width: Spacing.x2),
                        Text(
                          l10n.categoryIndustrial,
                          style: TextStyle(
                            fontWeight: query.category == ProductCategory.industrial
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: query.category == ProductCategory.industrial
                                ? AppColors.primary
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: ProductCategory.accessory.name,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.build_rounded,
                          size: 18,
                          color: query.category == ProductCategory.accessory
                              ? AppColors.primary
                              : AppColors.ink,
                        ),
                        const SizedBox(width: Spacing.x2),
                        Text(
                          l10n.categoryAccessory,
                          style: TextStyle(
                            fontWeight: query.category == ProductCategory.accessory
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: query.category == ProductCategory.accessory
                                ? AppColors.primary
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Vertical Border Divider 2
            Container(
              width: 1,
              color: AppColors.border,
            ),

            // 3. Customer Service Button (Segment 3)
            Expanded(
              child: _FixedActionSegmentButton(
                label: 'Service',
                trailingIcon: Icons.keyboard_arrow_down_rounded,
                onTap: () => ServiceContactSheet.show(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FixedSegmentButton<T> extends StatelessWidget {
  const _FixedSegmentButton({
    required this.label,
    required this.isActive,
    required this.selectedValue,
    required this.onSelected,
    required this.items,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final bool isActive;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final List<PopupMenuEntry<T>> items;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: AppColors.primaryTint.withOpacity(0.3),
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<T>(
        onSelected: onSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 4,
        position: PopupMenuPosition.under,
        offset: const Offset(0, 6),
        itemBuilder: (BuildContext context) => items,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.x2,
            vertical: 12,
          ),
          color: isActive ? AppColors.primaryTint.withOpacity(0.3) : Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              if (leadingIcon != null) ...<Widget>[
                Icon(
                  leadingIcon,
                  size: 18,
                  color: isActive ? AppColors.primary : AppColors.ink,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: isActive ? AppColors.primary : AppColors.ink,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (trailingIcon != null) ...<Widget>[
                const SizedBox(width: 2),
                Icon(
                  trailingIcon,
                  size: 18,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FixedActionSegmentButton extends StatelessWidget {
  const _FixedActionSegmentButton({
    required this.label,
    required this.onTap,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.x2,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (trailingIcon != null) ...<Widget>[
                const SizedBox(width: 2),
                Icon(
                  trailingIcon,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Service and Support form sheet presented when tapping the Service option.
class ServiceContactSheet extends ConsumerStatefulWidget {
  /// Creates the service contact sheet.
  const ServiceContactSheet({super.key});

  /// Shows the service form modal sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const ServiceContactSheet(),
    );
  }

  @override
  ConsumerState<ServiceContactSheet> createState() => _ServiceContactSheetState();
}

class _ServiceContactSheetState extends ConsumerState<ServiceContactSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionControllerProvider).valueOrNull;
    final profile = session is SessionSignedIn ? session.profile : null;

    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
    _detailsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitToWhatsApp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final details = _detailsController.text.trim();

    final addressStr = address.isEmpty ? 'Not specified' : address;
    final detailsStr = details.isEmpty ? 'General Service Inquiry' : details;

    final message = '''
*Service & Support Request*
🛠️ *Maruti Water Solution*

👤 *Name:* $name
📞 *Phone:* $phone
📍 *Address:* $addressStr

📝 *Service Details:*
$detailsStr
''';

    Navigator.of(context).pop();

    final success = await ContactLauncher.openWhatsApp(
      prefilledMessage: message,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp. Please ensure WhatsApp is installed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Handle bar
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
                        color: const Color(0xFF25D366).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.headset_mic_rounded,
                        color: Color(0xFF25D366),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: Spacing.x3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Service Request',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            'Fill details to contact support via WhatsApp',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: Spacing.x4),
                const Divider(color: AppColors.border),
                const SizedBox(height: Spacing.x3),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: Spacing.x3),

                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: 'Enter 10-digit mobile number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.trim().replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: Spacing.x3),

                // Address Field (Optional)
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                    hintText: 'Enter your full service address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: Spacing.x3),

                // Details Field (Optional)
                TextFormField(
                  controller: _detailsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Service Details / Requirements (Optional)',
                    hintText: 'Describe service issue, maintenance, or inquiry',
                    prefixIcon: Icon(Icons.build_outlined),
                  ),
                ),

                const SizedBox(height: Spacing.x5),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _submitToWhatsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: const Text(
                      'Submit via WhatsApp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

