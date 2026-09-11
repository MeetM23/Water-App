import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/errors/failure_presentation.dart';
import '../../../../data/repositories/supabase_unit_repository.dart';
import '../../../../domain/models/product_unit.dart';



/// Screen for registering a physical RO machine unit by serial number (MWS-SN).
class ProductRegistrationScreen extends ConsumerStatefulWidget {
  /// Creates product registration screen.
  const ProductRegistrationScreen({
    super.key,
    this.initialSerial,
  });

  /// Pre-filled unit serial number (MWS-SN).
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
    if (widget.initialSerial != null && widget.initialSerial!.trim().isNotEmpty) {
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

    if (clean.startsWith('MWS-DOM') || clean.startsWith('MWS-COM') || clean.startsWith('MWS-IND') || clean.startsWith('MWS-SPR') || clean.startsWith('MWS-ACC')) {
      setState(() {
        _isSearching = false;
        _foundUnit = null;
        _searchError = 'Please enter or scan a physical unit serial (MWS-SN-...). Catalogue codes (MWS-DOM-...) cannot be registered.';
      });
      return;
    }

    if (!clean.startsWith('MWS-SN-')) {
      setState(() {
        _isSearching = false;
        _foundUnit = null;
        _searchError = 'Invalid serial format. Physical unit serials must start with MWS-SN-';
      });
      return;
    }

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
          _foundUnit = unit;
          if (unit == null) {
            _searchError = 'Physical unit not found for serial "$clean"';
          }
        });
      },
      onFailure: (failure) {
        setState(() {
          _isSearching = false;
          _searchError = 'Failed to load serial details. Please try again.';
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
      AppSnackbar.error(context, 'Please enter and verify a valid serial number first');
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
      customerCity: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      customerAddress: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      purchaseDate: _installationDate,
      installationDate: _installationDate,
      warrantyMonths: unit.defaultWarrantyMonths ?? 12,
      invoiceNumber: _invoiceController.text.trim().isEmpty ? null : _invoiceController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      onSuccess: (regInfo) {
        AppSnackbar.success(
          context,
          'Unit ${unit.serialNumber} registered successfully for ${regInfo.customerName}!',
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
              // Unit Serial Lookup Card
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
                          const SizedBox(width: Spacing.x2),
                          Text(
                            'Physical Unit Lookup',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.x3),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _serialController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'Unit Serial Number (MWS-SN)',
                                hintText: 'e.g. MWS-SN-DOM-001001-K',
                                prefixIcon: Icon(Icons.confirmation_number_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Serial number is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () => context.push(AppRoutes.retailerScan),
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                            tooltip: 'Scan QR Code',
                          ),
                          const SizedBox(width: Spacing.x2),
                          IconButton.filled(
                            onPressed: _isSearching
                                ? null
                                : () => _lookupUnit(_serialController.text),
                            icon: _isSearching
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.search_rounded),
                          ),
                        ],
                      ),
                      if (_searchError != null) ...<Widget>[
                        const SizedBox(height: Spacing.x2),
                        Text(
                          _searchError!,
                          style: context.textTheme.bodySmall?.copyWith(color: AppColors.danger),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Physical Machine Details (if found)
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
                            const Icon(Icons.water_drop_outlined, color: AppColors.primary),
                            const SizedBox(width: Spacing.x2),
                            Expanded(
                              child: Text(
                                _foundUnit!.productName,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.x2),
                        Text(
                          'Model: ${_foundUnit!.modelNumber ?? "Standard RO"} | Serial: ${_foundUnit!.serialNumber}',
                          style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                        ),
                        Text(
                          'Default Warranty: ${_foundUnit!.defaultWarrantyMonths ?? 12} Months',
                          style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Duplicate Registration Warning Banner
              if (isAlreadyRegistered) ...<Widget>[
                const SizedBox(height: Spacing.x4),
                Container(
                  padding: const EdgeInsets.all(Spacing.x4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                        Row(
                          children: <Widget>[
                            const Icon(Icons.warning_amber_rounded, color: Colors.amber),
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
                          'Registered Customer: ${_foundUnit!.registration!.customerName}',
                          style: context.textTheme.bodyMedium,
                        ),
                        Text(
                          'Contact Phone: ${_foundUnit!.registration!.customerPhone}',
                          style: context.textTheme.bodyMedium,
                        ),
                        Text(
                          'Installation Date: ${_foundUnit!.registration!.installationDate.day}/${_foundUnit!.registration!.installationDate.month}/${_foundUnit!.registration!.installationDate.year}',
                          style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                ),
              ],


              // Customer Details Form (only enabled if not already registered)
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
                            const Icon(Icons.person_outline, color: AppColors.primary),
                            const SizedBox(width: Spacing.x2),
                            Text(
                              'Customer Information',
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
                            prefixIcon: Icon(Icons.location_city_outlined),
                          ),
                        ),
                        const SizedBox(height: Spacing.x3),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Installation Address',
                            hintText: 'Area, Street, Pincode',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: Spacing.x3),
                        TextFormField(
                          controller: _invoiceController,
                          decoration: const InputDecoration(
                            labelText: 'Invoice / Bill Number',
                            hintText: 'e.g. INV-99382',
                            prefixIcon: Icon(Icons.receipt_long_outlined),
                          ),
                        ),
                        const SizedBox(height: Spacing.x3),
                        InkWell(
                          onTap: _selectInstallationDate,
                          borderRadius: AppRadius.cardAll,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Installation Date',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
