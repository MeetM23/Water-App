import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/errors/failure_presentation.dart';
import '../../../../data/repositories/supabase_unit_repository.dart';
import '../../../../data/repositories/supabase_warranty_claim_repository.dart';
import '../../../../domain/models/product_unit.dart';
import '../../scanner/presentation/scanner_screen.dart';


/// Dedicated screen for Warranty & Claim registration for physical RO units.
class WarrantyClaimScreen extends ConsumerStatefulWidget {
  /// Creates warranty claim screen.
  const WarrantyClaimScreen({
    super.key,
    this.initialSerial,
  });

  /// Pre-filled unit serial number (MWS-SN).
  final String? initialSerial;

  @override
  ConsumerState<WarrantyClaimScreen> createState() => _WarrantyClaimScreenState();
}

class _WarrantyClaimScreenState extends ConsumerState<WarrantyClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serialController;
  final _contactPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedClaimType = 'Warranty Claim';
  bool _isSearching = false;
  bool _isSubmitting = false;
  ProductUnit? _foundUnit;
  String? _searchError;

  static const List<String> _claimTypes = <String>[
    'Warranty Claim',
    'Part Replacement',
    'Performance Issue',
    'Free Service Request',
    'Other Warranty Query',
  ];

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
    _contactPhoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _lookupUnit(String serial) async {
    final clean = serial.trim().toUpperCase();
    if (clean.isEmpty) return;

    if (clean.startsWith('MWS-DOM') || clean.startsWith('MWS-COM') || clean.startsWith('MWS-IND') || clean.startsWith('MWS-SPR') || clean.startsWith('MWS-ACC')) {
      setState(() {
        _isSearching = false;
        _foundUnit = null;
        _searchError = 'Please enter or scan a physical unit serial (MWS-SN-...). Catalogue codes (MWS-DOM-...) cannot be used for warranty claims.';
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

  Future<void> _submitClaim() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final unit = _foundUnit;
    if (unit == null) {
      AppSnackbar.error(context, 'Please enter and verify a valid unit serial number first');
      return;
    }

    setState(() => _isSubmitting = true);

    final repository = ref.read(warrantyClaimRepositoryProvider);
    final result = await repository.submitClaim(
      unitId: unit.unitId,
      claimType: _selectedClaimType,
      description: _descriptionController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      onSuccess: (claim) {
        AppSnackbar.success(
          context,
          'Warranty Claim submitted! Claim Number: ${claim.claimNumber}',
        );
        context.pop();
      },
      onFailure: (failure) {
        AppSnackbar.error(
          context,
          'Claim submission failed: ${failure.message(context.l10n)}',
        );
      },
    );
  }



  Future<void> _scanSerialWithCamera() async {
    final scannedCode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Scaffold(
        appBar: AppBar(
          title: const Text('Scan Physical Unit Serial'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(sheetContext),
          ),
        ),
        body: ScannerScreen(
          onClose: () => Navigator.pop(sheetContext),
          productRoute: (code) {
            Navigator.pop(sheetContext, code);
            return '';
          },
        ),
      ),
    );

    if (scannedCode != null && scannedCode.trim().isNotEmpty) {
      _serialController.text = scannedCode.trim().toUpperCase();
      _lookupUnit(scannedCode.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim / Warranty'),
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
                          const Icon(Icons.verified_outlined, color: AppColors.primary),
                          const SizedBox(width: Spacing.x2),
                          Text(
                            'Warranty Unit Lookup',
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
                                prefixIcon: Icon(Icons.qr_code_2_rounded),
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
                            onPressed: _scanSerialWithCamera,
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

              // Loaded Unit & Warranty Status Card
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
                        const SizedBox(height: Spacing.x2),
                        if (_foundUnit!.registration != null) ...<Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _foundUnit!.registration!.isExpired
                                  ? Colors.red.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _foundUnit!.registration!.isExpired
                                  ? 'Warranty Status: EXPIRED'
                                  : 'Warranty Status: ACTIVE',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _foundUnit!.registration!.isExpired
                                    ? AppColors.danger
                                    : Colors.green.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.x1),
                          Text(
                            'Customer: ${_foundUnit!.registration!.customerName} (${_foundUnit!.registration!.customerPhone})',
                            style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                          ),
                          Text(
                            'Valid until: ${_foundUnit!.registration!.warrantyEndDate.day}/${_foundUnit!.registration!.warrantyEndDate.month}/${_foundUnit!.registration!.warrantyEndDate.year}',
                            style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                          ),
                        ] else ...<Widget>[
                          Text(
                            'Warranty Status: Unregistered unit',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              // Claim Type & Details Form
              const SizedBox(height: Spacing.x4),
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.assignment_outlined, color: AppColors.primary),
                          const SizedBox(width: Spacing.x2),
                          Text(
                            'Claim Request Form',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.x3),
                      DropdownButtonFormField<String>(
                        value: _selectedClaimType,
                        decoration: const InputDecoration(
                          labelText: 'Claim Type',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _claimTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedClaimType = value);
                          }
                        },
                      ),
                      const SizedBox(height: Spacing.x3),
                      TextFormField(
                        controller: _contactPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Contact Mobile Number',
                          hintText: '10-digit phone number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 10) {
                            return 'Valid 10-digit phone number required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.x3),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Warranty Issue Description',
                          hintText: 'Describe the issue or claim details...',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please describe the issue';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.x6),
              AppButton(
                label: 'Submit Warranty Claim',
                isLoading: _isSubmitting,
                onPressed: (_isSubmitting || _foundUnit == null)
                    ? null
                    : _submitClaim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
