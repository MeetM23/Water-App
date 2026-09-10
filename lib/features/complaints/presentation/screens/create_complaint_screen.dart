import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/failure_presentation.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/repositories/supabase_catalog_repository.dart';
import '../../../../domain/enums/complaint_category.dart';
import '../../../../domain/enums/complaint_priority.dart';
import '../../../../domain/models/catalog_product.dart';
import '../../application/user_complaints_controller.dart';

/// Form for submitting a new complaint ticket.
class CreateComplaintScreen extends ConsumerStatefulWidget {
  /// Creates the submission screen with optional initial unit metadata.
  const CreateComplaintScreen({
    super.key,
    this.initialUnitId,
    this.initialProductModel,
    this.initialReference,
    this.initialCategory,
  });

  final String? initialUnitId;
  final String? initialProductModel;
  final String? initialReference;
  final ComplaintCategory? initialCategory;

  @override
  ConsumerState<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends ConsumerState<CreateComplaintScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  ComplaintCategory _category = ComplaintCategory.productIssue;
  ComplaintPriority _priority = ComplaintPriority.medium;
  CatalogProduct? _selectedProduct;
  bool _isSubmitting = false;

  final List<({String fileName, Uint8List bytes})> _pickedAttachments = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialReference != null && widget.initialReference!.isNotEmpty) {
      _referenceController.text = widget.initialReference!;
    }
    if (widget.initialCategory != null) {
      _category = widget.initialCategory!;
    } else if (widget.initialUnitId != null) {
      _category = ComplaintCategory.warrantyIssue;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedAttachments.add((fileName: image.name, bytes: bytes));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final (:complaint, :failure) = await ref
        .read(userComplaintsControllerProvider.notifier)
        .submitComplaint(
          subject: _subjectController.text.trim(),
          category: _category,
          description: _descriptionController.text.trim(),
          priority: _priority,
          productId: _selectedProduct?.id,
          unitId: widget.initialUnitId,
          referenceNumber: _referenceController.text.trim(),
          attachmentFiles: _pickedAttachments,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (failure != null) {
      AppSnackbar.error(context, failure.title(context.l10n));
      return;
    }

    if (complaint != null) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(context.l10n.complaintSubmittedTitle),
            content: Text(
              context.l10n.complaintSubmittedBody(complaint.ticketNumber),
            ),
            actions: <Widget>[
              AppButton(
                label: context.l10n.actionClose,
                onPressed: () => Navigator.of(dialogContext).pop(),
                isExpanded: false,
              ),
            ],
          );
        },
      );
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.complaintNewButton),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.x4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppTextField(
                label: l10n.complaintFieldSubject,
                controller: _subjectController,
                textInputAction: TextInputAction.next,
                isEnabled: !_isSubmitting,
                validator: (value) => Validators.required(value, l10n, l10n.complaintFieldSubject),
              ),
              const SizedBox(height: Spacing.x4),

              // Category dropdown
              DropdownButtonFormField<ComplaintCategory>(
                value: _category,
                decoration: InputDecoration(
                  labelText: l10n.complaintFieldCategory,
                  border: const OutlineInputBorder(),
                ),
                items: ComplaintCategory.values.map((cat) {
                  return DropdownMenuItem<ComplaintCategory>(
                    value: cat,
                    child: Text(_categoryLabel(cat, l10n)),
                  );
                }).toList(),
                onChanged: _isSubmitting ? null : (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: Spacing.x4),

              // Product Picker Dropdown
              Consumer(
                builder: (context, ref, child) {
                  final catalogAsync = ref.watch(catalogRepositoryProvider);
                  return FutureBuilder(
                    future: catalogAsync.fetchCatalogue(),
                    builder: (context, snapshot) {
                      final products = snapshot.data?.valueOrNull ?? <CatalogProduct>[];
                      return DropdownButtonFormField<CatalogProduct?>(
                        value: _selectedProduct,
                        decoration: InputDecoration(
                          labelText: l10n.complaintFieldProduct,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<CatalogProduct?>(
                            value: null,
                            child: Text('None'),
                          ),
                          ...products.map((p) => DropdownMenuItem<CatalogProduct?>(
                                value: p,
                                child: Text('${p.name} (${p.productCode})'),
                              )),
                        ],
                        onChanged: _isSubmitting ? null : (val) => setState(() => _selectedProduct = val),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: Spacing.x4),

              AppTextField(
                label: l10n.complaintFieldReference,
                controller: _referenceController,
                textInputAction: TextInputAction.next,
                isEnabled: !_isSubmitting,
              ),
              const SizedBox(height: Spacing.x4),

              // Priority dropdown
              DropdownButtonFormField<ComplaintPriority>(
                value: _priority,
                decoration: InputDecoration(
                  labelText: l10n.complaintFieldPriority,
                  border: const OutlineInputBorder(),
                ),
                items: ComplaintPriority.values.map((prio) {
                  return DropdownMenuItem<ComplaintPriority>(
                    value: prio,
                    child: Text(_priorityLabel(prio, l10n)),
                  );
                }).toList(),
                onChanged: _isSubmitting ? null : (val) => setState(() => _priority = val!),
              ),
              const SizedBox(height: Spacing.x4),

              AppTextField(
                label: l10n.complaintFieldDescription,
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                isEnabled: !_isSubmitting,
                validator: (value) => Validators.required(value, l10n, l10n.complaintFieldDescription),
              ),
              const SizedBox(height: Spacing.x5),

              // Attachments picker
              Text(
                l10n.complaintFieldAttachments,
                style: context.textTheme.titleSmall?.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: Spacing.x2),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._pickedAttachments.map(
                    (att) => Chip(
                      label: Text(att.fileName, overflow: TextOverflow.ellipsis),
                      onDeleted: () => setState(() => _pickedAttachments.remove(att)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _pickImage,
                    icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                    label: Text(l10n.complaintAddPhoto),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.x6),

              AppButton(
                label: l10n.complaintSubmitButton,
                onPressed: _submit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(ComplaintCategory cat, dynamic l10n) => switch (cat) {
        ComplaintCategory.productIssue => l10n.complaintCategoryProductIssue,
        ComplaintCategory.installationIssue => l10n.complaintCategoryInstallationIssue,
        ComplaintCategory.warrantyIssue => l10n.complaintCategoryWarrantyIssue,
        ComplaintCategory.deliveryIssue => l10n.complaintCategoryDeliveryIssue,
        ComplaintCategory.billingIssue => l10n.complaintCategoryBillingIssue,
        ComplaintCategory.technicalIssue => l10n.complaintCategoryTechnicalIssue,
        ComplaintCategory.other => l10n.complaintCategoryOther,
      };

  String _priorityLabel(ComplaintPriority prio, dynamic l10n) => switch (prio) {
        ComplaintPriority.low => l10n.complaintPriorityLow,
        ComplaintPriority.medium => l10n.complaintPriorityMedium,
        ComplaintPriority.high => l10n.complaintPriorityHigh,
        ComplaintPriority.urgent => l10n.complaintPriorityUrgent,
      };
}
