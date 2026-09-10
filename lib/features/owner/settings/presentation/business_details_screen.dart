import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_presentation.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../domain/models/business_settings.dart';
import '../application/business_settings_controller.dart';

/// Edits the business details that end up on printed labels.
///
/// The live preview is the point of the screen: an address that is three words
/// too long is invisible in a text field and obvious the moment it is drawn at
/// label width, which is the difference between noticing here and noticing
/// after a hundred labels are printed.
class BusinessDetailsScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const BusinessDetailsScreen({super.key});

  @override
  ConsumerState<BusinessDetailsScreen> createState() =>
      _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _address = TextEditingController();

  bool _hasSeeded = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _seed(BusinessSettings settings) {
    if (_hasSeeded) {
      return;
    }
    _hasSeeded = true;
    _name.text = settings.businessName;
    _phone.text = settings.phone;
    _address.text = settings.address;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final l10n = context.l10n;
    setState(() => _isSaving = true);

    final failure = await ref
        .read(businessSettingsControllerProvider.notifier)
        .save(
          BusinessSettings(
            businessName: _name.text,
            phone: _phone.text,
            address: _address.text,
          ),
        );

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);

    if (failure != null) {
      // The fields keep what was typed: a failed save must not cost the owner
      // their address a second time.
      AppSnackbar.error(context, failure.title(l10n));
      return;
    }
    AppSnackbar.success(context, l10n.businessSaved);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(businessSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessTitle)),
      body: settings.when(
        loading: () => const _Skeleton(),
        error: (Object error, StackTrace stackTrace) => AppErrorState(
          failure: error is AppFailure
              ? error
              : UnexpectedFailure(cause: error, stackTrace: stackTrace),
          onRetry: () =>
              ref.read(businessSettingsControllerProvider.notifier).refresh(),
        ),
        data: (BusinessSettings value) {
          _seed(value);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(Spacing.x4),
              children: <Widget>[
                Text(
                  l10n.businessIntro,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: Spacing.x6),
                AppTextField(
                  label: l10n.businessNameLabel,
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  validator: (String? value) =>
                      Validators.name(value, l10n, l10n.businessNameLabel),
                ),
                const SizedBox(height: Spacing.x5),
                AppTextField(
                  label: l10n.businessPhoneLabel,
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  trailingLabel: l10n.fieldOptional,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: Spacing.x5),
                AppTextField(
                  label: l10n.businessAddressLabel,
                  controller: _address,
                  textCapitalization: TextCapitalization.words,
                  trailingLabel: l10n.fieldOptional,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: Spacing.x8),
                Text(
                  l10n.businessPreview.toUpperCase(),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: Spacing.x3),
                _LabelPreview(
                  settings: BusinessSettings(
                    businessName: _name.text,
                    phone: _phone.text,
                    address: _address.text,
                  ),
                ),
                const SizedBox(height: Spacing.x8),
                AppButton(
                  label: l10n.actionSave,
                  onPressed: _save,
                  isLoading: _isSaving,
                ),
                const SizedBox(height: Spacing.x10),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A rough rendering of the top of a printed label.
///
/// Deliberately not pixel-exact against the PDF: it exists to show how much
/// text fits, and it clips at one line exactly as the real label does.
class _LabelPreview extends StatelessWidget {
  const _LabelPreview({required this.settings});

  final BusinessSettings settings;

  @override
  Widget build(BuildContext context) {
    final footer = settings.labelFooter;

    return AppCard(
      child: Container(
        padding: const EdgeInsets.all(Spacing.x3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.controlAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              settings.businessName.trim().toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.ink,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (footer != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                footer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
            const SizedBox(height: Spacing.x2),
            Container(height: 26, color: AppColors.skeletonBase),
            const SizedBox(height: 2),
            Text(
              'MWS-DOM-001042-Z',
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: Padding(
        padding: EdgeInsets.all(Spacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSkeleton(height: 32),
            SizedBox(height: Spacing.x6),
            AppSkeleton(height: 48),
            SizedBox(height: Spacing.x5),
            AppSkeleton(height: 48),
            SizedBox(height: Spacing.x5),
            AppSkeleton(height: 48),
          ],
        ),
      ),
    );
  }
}
