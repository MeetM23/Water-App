import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_presentation.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../domain/models/product_draft.dart';
import '../application/product_form_controller.dart';
import '../application/product_list_controller.dart';
import 'sections/availability_section.dart';
import 'sections/barcode_mode_section.dart';
import 'sections/basic_details_section.dart';
import 'sections/photos_section.dart';
import 'sections/pricing_section.dart';
import 'sections/specifications_section.dart';
import 'widgets/product_created_sheet.dart';

/// Create or edit a product.
///
/// The draft lives in the controller, not in this widget, so a failed save
/// keeps every field exactly as the owner left it.
class ProductFormScreen extends ConsumerStatefulWidget {
  /// Creates the form. A null [productId] means a new product.
  const ProductFormScreen({super.key, this.productId});

  /// Which product is being edited, or null when creating.
  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{
        for (final field in _FormField.values)
          field.name: TextEditingController(),
      };

  bool _isSaving = false;
  bool _hasSeededControllers = false;

  /// Whether Save has been pressed at least once.
  ///
  /// The category chips have no focus of their own, so there is no blur to
  /// validate on. Showing "Category is required" the instant a blank form
  /// opens scolds the owner for not having filled in a form they have not
  /// started; the message waits for a submit attempt instead.
  bool _hasAttemptedSubmit = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(_FormField field) =>
      _controllers[field.name]!;

  /// Fills the text controllers once, when an existing product has loaded.
  void _seed(ProductDraft draft) {
    if (_hasSeededControllers) {
      return;
    }
    _hasSeededControllers = true;
    _controller(_FormField.name).text = draft.name;
    _controller(_FormField.model).text = draft.modelNumber;
    _controller(_FormField.description).text = draft.description;
    _controller(_FormField.capacity).text = draft.capacity;
    _controller(_FormField.mrp).text = draft.mrp;
    _controller(_FormField.wholesale).text = draft.wholesalePrice;
    _controller(_FormField.retail).text = draft.retailPrice;
    _controller(_FormField.stockQuantity).text = draft.stockQuantity;
    _controller(_FormField.customCode).text = draft.customCode;
  }

  Future<bool> _confirmDiscard() async {
    final notifier = ref.read(
      productFormControllerProvider(widget.productId).notifier,
    );
    if (!notifier.isDirty) {
      await notifier.discardUploads();
      return true;
    }

    final l10n = context.l10n;
    final discard = await AppConfirmDialog.show(
      context,
      title: l10n.unsavedTitle,
      message: l10n.unsavedBody,
      confirmLabel: l10n.unsavedDiscard,
      cancelLabel: l10n.unsavedKeepEditing,
      isDestructive: true,
    );
    if (discard) {
      await notifier.discardUploads();
    }
    return discard;
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final notifier = ref.read(
      productFormControllerProvider(widget.productId).notifier,
    );

    setState(() => _hasAttemptedSubmit = true);

    if (!(_formKey.currentState?.validate() ?? false) || !notifier.canSubmit) {
      if (notifier.canSubmit == false && mounted) {
        final draft = ref
            .read(productFormControllerProvider(widget.productId))
            .valueOrNull;
        if (draft?.hasUploadsInFlight ?? false) {
          AppSnackbar.show(context, l10n.formUploadsInFlight);
        }
      }
      return;
    }

    setState(() => _isSaving = true);
    final outcome = await notifier.save();
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);

    if (outcome.failure != null) {
      // The draft is untouched, so every field the owner typed is still here.
      AppSnackbar.error(context, outcome.failure!.title(context.l10n));
      return;
    }

    await ref.read(productListControllerProvider.notifier).refresh();
    if (!mounted) {
      return;
    }

    final product = outcome.product!;
    final isNew = widget.productId == null;
    if (isNew) {
      await ProductCreatedSheet.show(context, product: product);
    } else {
      AppSnackbar.success(context, l10n.productSaved);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formState = ref.watch(
      productFormControllerProvider(widget.productId),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        if (await _confirmDiscard()) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.productId == null ? l10n.formNewTitle : l10n.formEditTitle,
          ),
        ),
        body: formState.when(
          loading: () => const _FormSkeleton(),
          error: (Object error, StackTrace stackTrace) => AppErrorState(
            failure: error is AppFailure
                ? error
                : UnexpectedFailure(cause: error, stackTrace: stackTrace),
            onRetry: () =>
                ref.invalidate(productFormControllerProvider(widget.productId)),
          ),
          data: (ProductDraft draft) {
            _seed(draft);
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.x4,
                  Spacing.x5,
                  Spacing.x4,
                  Spacing.x10,
                ),
                children: <Widget>[
                  _SectionHeader(label: l10n.sectionPhotos),
                  PhotosSection(productId: widget.productId, draft: draft),
                  const SizedBox(height: Spacing.x8),
                  _SectionHeader(label: l10n.sectionBasics),
                  BasicDetailsSection(
                    productId: widget.productId,
                    draft: draft,
                    nameController: _controller(_FormField.name),
                    modelController: _controller(_FormField.model),
                    descriptionController: _controller(_FormField.description),
                    hasAttemptedSubmit: _hasAttemptedSubmit,
                  ),
                  const SizedBox(height: Spacing.x8),
                  _SectionHeader(label: l10n.sectionSpecifications),
                  SpecificationsSection(
                    productId: widget.productId,
                    draft: draft,
                    capacityController: _controller(_FormField.capacity),
                  ),
                  const SizedBox(height: Spacing.x8),
                  _SectionHeader(label: l10n.sectionPricing),
                  PricingSection(
                    productId: widget.productId,
                    draft: draft,
                    mrpController: _controller(_FormField.mrp),
                    wholesaleController: _controller(_FormField.wholesale),
                    retailController: _controller(_FormField.retail),
                  ),
                  const SizedBox(height: Spacing.x8),
                  BarcodeModeSection(
                    productId: widget.productId,
                    draft: draft,
                    customCodeController: _controller(_FormField.customCode),
                  ),
                  const SizedBox(height: Spacing.x8),
                  _SectionHeader(label: l10n.sectionAvailability),
                  AvailabilitySection(
                    productId: widget.productId,
                    draft: draft,
                    stockQuantityController: _controller(_FormField.stockQuantity),
                  ),
                  const SizedBox(height: Spacing.x10),
                  AppButton(
                    label: l10n.actionSave,
                    onPressed: _save,
                    isLoading: _isSaving,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Identifiers for the text controllers this form owns.
enum _FormField { name, model, description, capacity, mrp, wholesale, retail, stockQuantity, customCode }

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.x4),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _FormSkeleton extends StatelessWidget {
  const _FormSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: Padding(
        padding: EdgeInsets.all(Spacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSkeleton(width: 120, height: 12),
            SizedBox(height: Spacing.x4),
            AppSkeleton(height: 100),
            SizedBox(height: Spacing.x8),
            AppSkeleton(width: 140, height: 12),
            SizedBox(height: Spacing.x4),
            AppSkeleton(height: 48),
            SizedBox(height: Spacing.x4),
            AppSkeleton(height: 48),
            SizedBox(height: Spacing.x4),
            AppSkeleton(height: 48),
          ],
        ),
      ),
    );
  }
}
