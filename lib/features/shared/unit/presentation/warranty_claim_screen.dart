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
import '../../../../data/repositories/supabase_warranty_claim_repository.dart';
import '../../../../domain/enums/product_category.dart';
import '../../../../domain/models/product_unit.dart';

/// Screen for submitting a warranty or service claim on a physical RO unit.
///
/// The user arrives here from:
///   1. The Scanner tab "Claim / Warranty" action tile — which switches the
///      scanner to MWS-SN mode and passes the scanned serial via [initialSerial].
///   2. The Account screen, opening the form directly. The scan button inside
///      the form pushes [AppRoutes.serialScanClaim] as a full-screen scanner
///      route; the serial comes back via the URI query parameter 'serialNumber'.
class WarrantyClaimScreen extends ConsumerStatefulWidget {
  /// Creates warranty claim screen.
  const WarrantyClaimScreen({
    super.key,
    this.initialSerial,
  });

  /// Pre-filled unit serial number (MWS-SN), typically from a QR scan.
  final String? initialSerial;

  @override
  ConsumerState<WarrantyClaimScreen> createState() =>
      _WarrantyClaimScreenState();
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
    _serialController =
        TextEditingController(text: widget.initialSerial ?? '');
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
    _contactPhoneController.dispose();
    _descriptionController.dispose();
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

  Future<void> _submitClaim() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final unit = _foundUnit;
    if (unit == null) {
      AppSnackbar.error(
          context, 'Please scan or enter a valid unit serial first.');
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
          'Warranty claim submitted! Claim #: ${claim.claimNumber}',
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

  /// Opens the dedicated serial-scanner route configured for warranty claims.
  Future<void> _openSerialScanner() async {
    await context.push<void>(AppRoutes.serialScanClaim);
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
              // ── Step 1: Scan or enter the physical unit serial ──────────────
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.verified_outlined,
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
                        'Scan the QR label on the machine (MWS-SN-...) '
                        'or enter the serial manually.',
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
                          const SizedBox(width: Spacing.x2),
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
                                  style: context.textTheme.bodySmall
                                      ?.copyWith(color: AppColors.danger),
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

              // ── Resolved physical unit + warranty status ────────────────────
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
                                        ?.copyWith(
                                            color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.x3),
                        const Divider(),
                        const SizedBox(height: Spacing.x2),

                        // Serial
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.confirmation_number_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: Spacing.x2),
                            Expanded(
                              child: Text(
                                _foundUnit!.serialNumber,
                                style:
                                    context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: Spacing.x2),

                        // Warranty status badge
                        if (_foundUnit!.registration != null) ...<Widget>[
                          _WarrantyStatusBadge(
                            registration: _foundUnit!.registration!,
                          ),
                        ] else ...<Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.x2, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.orange.shade200),
                            ),
                            child: Text(
                              'Unregistered — no active warranty',
                              style:
                                  context.textTheme.bodySmall?.copyWith(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              // ── Step 2: Claim details ───────────────────────────────────────
              const SizedBox(height: Spacing.x4),
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.assignment_outlined,
                              color: AppColors.primary),
                          const SizedBox(width: Spacing.x2),
                          Text(
                            'Step 2 — Claim Details',
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
                          labelText: 'Issue Description',
                          hintText: 'Describe the problem or claim details...',
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
              const SizedBox(height: Spacing.x4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Warranty status badge shown in the unit details card.
class _WarrantyStatusBadge extends StatelessWidget {
  const _WarrantyStatusBadge({required this.registration});

  final dynamic registration; // UnitRegistration

  @override
  Widget build(BuildContext context) {
    final isExpired = registration.isExpired as bool;
    final endDate = registration.warrantyEndDate as DateTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.x2, vertical: 4),
          decoration: BoxDecoration(
            color: isExpired ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isExpired
                  ? Colors.red.shade200
                  : Colors.green.shade200,
            ),
          ),
          child: Text(
            isExpired ? 'Warranty EXPIRED' : 'Warranty ACTIVE',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      isExpired ? AppColors.danger : Colors.green.shade800,
                ),
          ),
        ),
        const SizedBox(height: Spacing.x1),
        Text(
          'Customer: ${registration.customerName} (${registration.customerPhone})',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey.shade700),
        ),
        Text(
          'Valid until: ${endDate.day}/${endDate.month}/${endDate.year}',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
