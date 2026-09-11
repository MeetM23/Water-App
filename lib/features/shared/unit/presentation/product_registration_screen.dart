import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/errors/failure_presentation.dart';
import '../../../../data/repositories/supabase_unit_repository.dart';
import '../../../../domain/enums/product_category.dart';
import '../../../../domain/models/product_unit.dart';

/// Screen for registering a physical RO machine unit by serial number (MWS-SN).
///
/// The user arrives here from:
///   1. The Scanner tab "Register Product" action tile — which switches the
///      scanner to MWS-SN mode and passes the scanned serial via [initialSerial].
///   2. The Account screen "My Registrations" button, where the form opens
///      first and the user can scan from inside the form via the scan icon
///      button, which pushes [AppRoutes.serialScanRegister] as a full-screen
///      scanner route. The serial comes back via the URI query parameter
///      'serialNumber' when the route is revisited.
class ProductRegistrationScreen extends ConsumerStatefulWidget {
  /// Creates product registration screen.
  const ProductRegistrationScreen({
    super.key,
    this.initialSerial,
  });

  /// Pre-filled unit serial number (MWS-SN), typically from a QR scan.
  final String? initialSerial;

  @override
  ConsumerState<ProductRegistrationScreen> createState() =>
      _ProductRegistrationScreenState();
}

class _ProductRegistrationScreenState
    extends ConsumerState<ProductRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serialController;
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _invoiceController = TextEditingController();
  DateTime _installationDate = DateTime.now();

  bool _isSearching = false;
  bool _isSubmitting = false;
  ProductUnit? _foundUnit;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _serialController = TextEditingController(text: widget.initialSerial ?? '');
    if (widget.initialSerial != null &&
        widget.initialSerial!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _lookupUnit(widget.initialSerial!.trim());
      });
    }
  }

  @override
  void dispose() {
    _serialController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  Future<void> _lookupUnit(String serial) async {
    final clean = serial.trim().toUpperCase();
    if (clean.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
      _foundUnit = null;
    });

    final repository = ref.read(unitRepositoryProvider);
    final result = await repository.findUnitBySerial(clean);

    if (!mounted) return;

    result.fold(
      onSuccess: (unit) {
        setState(() {
          _isSearching = false;
          _foundUnit = unit ??
              ProductUnit(
                unitId: clean,
                serialNumber: clean,
                productId: clean,
                productName: 'RO Water Purifier ($clean)',
                modelNumber: clean,
                category: ProductCategory.domestic,
                manufacturedAt: DateTime.now(),
              );
        });
      },
      onFailure: (failure) {
        setState(() {
          _isSearching = false;
          _foundUnit = ProductUnit(
            unitId: clean,
            serialNumber: clean,
            productId: clean,
            productName: 'RO Water Purifier ($clean)',
            modelNumber: clean,
            category: ProductCategory.domestic,
            manufacturedAt: DateTime.now(),
          );
        });
      },
    );
  }

  Future<void> _selectInstallationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _installationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _installationDate = picked;
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final unit = _foundUnit;
    if (unit == null) {
      AppSnackbar.error(
          context, 'Please scan or enter a valid serial number first.');
      return;
    }

    if (unit.registration != null) {
      AppSnackbar.error(context, 'This unit is already registered!');
      return;
    }

    setState(() => _isSubmitting = true);

    final repository = ref.read(unitRepositoryProvider);
    final result = await repository.registerUnit(
      unitId: unit.unitId,
      customerName: _customerNameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      customerCity: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      customerAddress: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      purchaseDate: _installationDate,
      installationDate: _installationDate,
      warrantyMonths: unit.defaultWarrantyMonths ?? 12,
      invoiceNumber: _invoiceController.text.trim().isEmpty
          ? null
          : _invoiceController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      onSuccess: (regInfo) {
        AppSnackbar.success(
          context,
          'Unit ${unit.serialNumber} registered for ${regInfo.customerName}!',
        );
        context.pop();
      },
      onFailure: (failure) {
        AppSnackbar.error(
          context,
          'Registration failed: ${failure.message(context.l10n)}',
        );
      },
    );
  }

  /// Opens the dedicated serial-scanner route.
  ///
  /// The scanner is configured for MWS-SN only (ScanMode.registerProduct).
  /// When it resolves a valid serial, it pushes /product-registration?serialNumber=...
  /// which re-opens this screen with the serial pre-filled. Because GoRouter
  /// replaces the current instance rather than stacking another one of the
  /// same route, the result arrives cleanly without navigation loops.
  Future<void> _openSerialScanner() async {
    await context.push<void>(AppRoutes.serialScanRegister);
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyRegistered = _foundUnit?.registration != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Product Unit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.x4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ── Step 1: Scan or enter the physical unit serial ─────────────
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.qr_code_2_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: Spacing.x2),
                          Text(
                            'Step 1 — Physical Unit',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.x1),
                      Text(
                        'Scan the QR code on the unit/box or type the serial manually.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: Spacing.x3),

                      // Primary action: scan button
                      AppButton(
                        label: 'Scan Physical Unit QR',
                        icon: Icons.qr_code_scanner_rounded,
                        onPressed: _isSearching ? null : _openSerialScanner,
                      ),

                      const SizedBox(height: Spacing.x3),

                      // Manual serial entry
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _serialController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'Physical Unit Serial (MWS-SN-...)',
                                hintText: 'e.g. MWS-SN-DOM-001001-K',
                                prefixIcon: Icon(
                                    Icons.confirmation_number_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Serial number is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: Spacing.x2),
                          // Search/verify button
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: IconButton.filled(
                              onPressed: _isSearching
                                  ? null
                                  : () =>
                                      _lookupUnit(_serialController.text),
                              icon: _isSearching
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.search_rounded),
                              tooltip: 'Look up serial',
                            ),
                          ),
                        ],
                      ),

                      if (_searchError != null) ...<Widget>[
                        const SizedBox(height: Spacing.x2),
                        Container(
                          padding: const EdgeInsets.all(Spacing.x3),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.08),
                            borderRadius: AppRadius.cardAll,
                            border: Border.all(
                                color: AppColors.danger.withOpacity(0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(Icons.error_outline_rounded,
                                  color: AppColors.danger, size: 18),
                              const SizedBox(width: Spacing.x2),
                              Expanded(
                                child: Text(
                                  _searchError!,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Resolved physical unit details ──────────────────────────────
              if (_foundUnit != null) ...<Widget>[
                const SizedBox(height: Spacing.x4),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.x4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: AppRadius.cardAll,
                              ),
                              child: const Icon(
                                Icons.water_drop_outlined,
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
                                    _foundUnit!.productName,
                                    style: context.textTheme.titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _foundUnit!.modelNumber != null
                                        ? 'Model: ${_foundUnit!.modelNumber}'
                                        : 'Standard RO',
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.x2, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.green.shade200),
                              ),
                              child: Text(
                                'Found',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.x3),
                        const Divider(),
                        const SizedBox(height: Spacing.x2),
                        _InfoRow(
                          label: 'Serial Number',
                          value: _foundUnit!.serialNumber,
                          icon: Icons.confirmation_number_outlined,
                        ),
                        const SizedBox(height: Spacing.x2),
                        _InfoRow(
                          label: 'Default Warranty',
                          value:
                              '${_foundUnit!.defaultWarrantyMonths ?? 12} months',
                          icon: Icons.verified_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Already registered warning ──────────────────────────────────
              if (isAlreadyRegistered) ...<Widget>[
                const SizedBox(height: Spacing.x4),
                Container(
                  padding: const EdgeInsets.all(Spacing.x4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: AppRadius.cardAll,
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.amber),
                          const SizedBox(width: Spacing.x2),
                          Text(
                            'Unit Already Registered',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.x2),
                      Text(
                        'Registered to: ${_foundUnit!.registration!.customerName}',
                        style: context.textTheme.bodyMedium,
                      ),
                      Text(
                        'Phone: ${_foundUnit!.registration!.customerPhone}',
                        style: context.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey.shade700),
                      ),
                      Text(
                        'Date: ${_foundUnit!.registration!.installationDate.day}/${_foundUnit!.registration!.installationDate.month}/${_foundUnit!.registration!.installationDate.year}',
                        style: context.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Step 2: Customer details ────────────────────────────────────
              if (!isAlreadyRegistered) ...<Widget>[
                const SizedBox(height: Spacing.x4),
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
                              'Step 2 — Customer Information',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.x3),
                        TextFormField(
                          controller: _customerNameController,
                          decoration: const InputDecoration(
                            labelText: 'Customer Name',
                            hintText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Customer name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: Spacing.x3),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Contact Mobile',
                            hintText: '10-digit mobile number',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().length < 10) {
                              return 'Valid 10-digit mobile number required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: Spacing.x3),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'City / Town',
                            hintText: 'e.g. Botad, Ahmedabad',
                            prefixIcon:
                                Icon(Icons.location_city_outlined),
                          ),
                        ),
                        const SizedBox(height: Spacing.x3),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Installation Address',
                            hintText: 'Area, Street, Pincode',
                            prefixIcon:
                                Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: Spacing.x3),
                        TextFormField(
                          controller: _invoiceController,
                          decoration: const InputDecoration(
                            labelText: 'Invoice / Bill Number',
                            hintText: 'e.g. INV-99382',
                            prefixIcon:
                                Icon(Icons.receipt_long_outlined),
                          ),
                        ),
                        const SizedBox(height: Spacing.x3),
                        InkWell(
                          onTap: _selectInstallationDate,
                          borderRadius: AppRadius.cardAll,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Installation Date',
                              prefixIcon:
                                  Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(
                              '${_installationDate.day}/${_installationDate.month}/${_installationDate.year}',
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.x6),
                AppButton(
                  label: 'Register Product Unit',
                  isLoading: _isSubmitting,
                  onPressed: (_isSubmitting || _foundUnit == null)
                      ? null
                      : _submitRegistration,
                ),
                const SizedBox(height: Spacing.x4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A small label + value row for the unit details card.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: Spacing.x2),
        Text(
          '$label: ',
          style: context.textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
