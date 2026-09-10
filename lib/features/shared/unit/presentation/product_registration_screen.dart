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
  final _addressController = TextEditingController();
  final _invoiceController = TextEditingController();
  DateTime _installationDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _serialController = TextEditingController(text: widget.initialSerial ?? '');
  }

  @override
  void dispose() {
    _serialController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _invoiceController.dispose();
    super.dispose();
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

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    AppSnackbar.success(
      context,
      'Product machine serial (${_serialController.text.trim()}) registered successfully!',
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.qr_code_2_rounded,
                              color: AppColors.primary),
                          const SizedBox(width: Spacing.x2),
                          Text(
                            'Unit Details',
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
                          prefixIcon: Icon(Icons.confirmation_number_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Serial number is required';
                          }
                          return null;
                        },
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
                          const Icon(Icons.person_outline,
                              color: AppColors.primary),
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
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Installation Address',
                          hintText: 'City, Area, Pincode',
                          prefixIcon: Icon(Icons.location_on_outlined),
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
                onPressed: _isSubmitting ? null : _submitRegistration,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
