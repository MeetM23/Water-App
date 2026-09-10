import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';

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
  bool _isSubmitting = false;

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
  }

  @override
  void dispose() {
    _serialController.dispose();
    _contactPhoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final serial = _serialController.text.trim();
    final claimId = 'CLM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    AppSnackbar.success(
      context,
      'Warranty Claim submitted successfully! Claim ID: $claimId (Serial: $serial)',
    );

    context.pop();
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
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.verified_outlined,
                              color: AppColors.primary),
                          const SizedBox(width: Spacing.x2),
                          Text(
                            'Warranty Details',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.x3),
                      TextFormField(
                        controller: _serialController,
                        decoration: const InputDecoration(
                          labelText: 'Unit Serial Number (MWS-SN)',
                          hintText: 'e.g. MWS-SN-2024-8842',
                          prefixIcon: Icon(Icons.qr_code_2_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Serial number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.x3),
                      DropdownButtonFormField<String>(
                        value: _selectedClaimType,
                        decoration: const InputDecoration(
                          labelText: 'Claim Type',
                          prefixIcon: Icon(Icons.assignment_outlined),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.x4),
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.phone_in_talk_outlined,
                              color: AppColors.primary),
                          const SizedBox(width: Spacing.x2),
                          Text(
                            'Contact & Issue Summary',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                onPressed: _isSubmitting ? null : _submitClaim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
