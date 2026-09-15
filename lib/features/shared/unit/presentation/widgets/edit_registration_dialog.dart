import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../domain/models/product_lookup.dart';

/// Clean modal dialog for editing a product registration.
class EditRegistrationDialog extends StatefulWidget {
  /// Creates the dialog.
  const EditRegistrationDialog({
    super.key,
    required this.initialReg,
  });

  /// Initial registration details.
  final ProductRegistrationInfo initialReg;

  /// Utility helper to present the dialog.
  static Future<Map<String, String?>?> show(
    BuildContext context,
    ProductRegistrationInfo reg,
  ) {
    return showDialog<Map<String, String?>?>(
      context: context,
      builder: (dialogCtx) => EditRegistrationDialog(initialReg: reg),
    );
  }

  @override
  State<EditRegistrationDialog> createState() => _EditRegistrationDialogState();
}

class _EditRegistrationDialogState extends State<EditRegistrationDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _invoiceCtrl;
  late final TextEditingController _sellerNameCtrl;
  late final TextEditingController _sellerPhoneCtrl;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final reg = widget.initialReg;
    _nameCtrl = TextEditingController(text: reg.customerName);
    _phoneCtrl = TextEditingController(text: reg.customerPhone);
    _cityCtrl = TextEditingController(text: reg.customerCity ?? '');
    _addressCtrl = TextEditingController(text: reg.customerAddress ?? '');
    _invoiceCtrl = TextEditingController(text: reg.invoiceNumber ?? '');
    _sellerNameCtrl = TextEditingController(text: reg.sellerName ?? '');
    _sellerPhoneCtrl = TextEditingController(text: reg.sellerPhone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _invoiceCtrl.dispose();
    _sellerNameCtrl.dispose();
    _sellerPhoneCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = <String, String?>{
      'customerName': _nameCtrl.text.trim(),
      'customerPhone': _phoneCtrl.text.trim(),
      'customerCity': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      'customerAddress': _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      'invoiceNumber': _invoiceCtrl.text.trim().isEmpty ? null : _invoiceCtrl.text.trim(),
      'sellerName': _sellerNameCtrl.text.trim().isEmpty ? null : _sellerNameCtrl.text.trim(),
      'sellerPhone': _sellerPhoneCtrl.text.trim().isEmpty ? null : _sellerPhoneCtrl.text.trim(),
    };

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Unit Registration'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Customer Name *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: Spacing.x2),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Customer Phone *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: Spacing.x2),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: 'City / Town'),
              ),
              const SizedBox(height: Spacing.x2),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: Spacing.x2),
              TextFormField(
                controller: _invoiceCtrl,
                decoration: const InputDecoration(labelText: 'Invoice Number'),
              ),
              const SizedBox(height: Spacing.x3),
              const Divider(),
              const SizedBox(height: Spacing.x2),
              TextFormField(
                controller: _sellerNameCtrl,
                decoration: const InputDecoration(labelText: 'Retailer / Wholesaler Name'),
              ),
              const SizedBox(height: Spacing.x2),
              TextFormField(
                controller: _sellerPhoneCtrl,
                decoration: const InputDecoration(labelText: 'Retailer / Wholesaler Mobile'),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
