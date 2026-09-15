import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failure_presentation.dart';
import '../../../core/extensions/build_context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../domain/enums/user_role.dart';
import '../../../domain/models/sign_up_request.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_shell.dart';
import 'widgets/role_selector.dart';

/// Dealer registration.
///
/// The account this creates is always pending: status is set by the database
/// trigger, not by anything sent from here.
class SignupScreen extends ConsumerStatefulWidget {
  /// Creates the sign-up screen.
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{
        for (final field in _SignupField.values)
          field.name: TextEditingController(),
      };

  UserRole _role = UserRole.retailer;

  @override
  void initState() {
    super.initState();
    _controllers[_SignupField.state.name]!.text = AppConfig.defaultState;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(_SignupField field) =>
      _controllers[field.name]!;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = SignUpRequest(
      email: _controller(_SignupField.email).text.trim(),
      password: _controller(_SignupField.password).text,
      fullName: _controller(_SignupField.fullName).text.trim(),
      firmName: _controller(_SignupField.firmName).text.trim(),
      phone: _controller(_SignupField.phone).text.trim(),
      city: _controller(_SignupField.city).text.trim(),
      state: _controller(_SignupField.state).text.trim(),
      role: _role,
      gstNumber: _controller(_SignupField.gstNumber).text.trim().toUpperCase(),
    );

    final failure = await ref
        .read(authControllerProvider.notifier)
        .signUp(request);

    if (!mounted) {
      return;
    }

    if (failure != null) {
      AppSnackbar.error(context, failure.title(context.l10n));
      return;
    }

    AppSnackbar.success(
      context,
      'Registration submitted successfully. Please sign in.',
    );
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSubmitting = ref.watch(authControllerProvider).isLoading;

    return AuthShell(
      title: l10n.signupTitle,
      subtitle: l10n.signupSubtitle,
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _SectionHeader(label: l10n.signupSectionAccount),
              AppTextField(
                label: l10n.fieldEmail,
                controller: _controller(_SignupField.email),
                hint: l10n.hintEmail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.mail_outline_rounded,
                autofillHints: const <String>[AutofillHints.email],
                isEnabled: !isSubmitting,
                validator: (String? value) => Validators.email(value, l10n),
              ),
              const SizedBox(height: Spacing.x5),
              AppTextField(
                label: l10n.fieldPassword,
                controller: _controller(_SignupField.password),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.lock_outline_rounded,
                autofillHints: const <String>[AutofillHints.newPassword],
                isObscured: true,
                isEnabled: !isSubmitting,
                validator: (String? value) => Validators.password(value, l10n),
              ),
              const SizedBox(height: Spacing.x6),
              _SectionHeader(label: l10n.signupSectionBusiness),
              AppTextField(
                label: l10n.fieldFullName,
                controller: _controller(_SignupField.fullName),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.person_outline_rounded,
                autofillHints: const <String>[AutofillHints.name],
                isEnabled: !isSubmitting,
                validator: (String? value) =>
                    Validators.name(value, l10n, l10n.fieldFullName),
              ),
              const SizedBox(height: Spacing.x5),
              AppTextField(
                label: l10n.fieldFirmName,
                controller: _controller(_SignupField.firmName),
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.business_outlined,
                isEnabled: !isSubmitting,
                validator: (String? value) =>
                    Validators.name(value, l10n, l10n.fieldFirmName),
              ),
              const SizedBox(height: Spacing.x5),
              AppTextField(
                label: l10n.fieldPhone,
                controller: _controller(_SignupField.phone),
                hint: l10n.hintPhone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.call_outlined,
                maxLength: 10,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                isEnabled: !isSubmitting,
                validator: (String? value) => Validators.phone(value, l10n),
              ),
              const SizedBox(height: Spacing.x5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: AppTextField(
                      label: l10n.fieldCity,
                      controller: _controller(_SignupField.city),
                      textInputAction: TextInputAction.next,
                      isEnabled: !isSubmitting,
                      validator: (String? value) =>
                          Validators.name(value, l10n, l10n.fieldCity),
                    ),
                  ),
                  const SizedBox(width: Spacing.x3),
                  Expanded(
                    child: AppTextField(
                      label: l10n.fieldState,
                      controller: _controller(_SignupField.state),
                      textInputAction: TextInputAction.next,
                      isEnabled: !isSubmitting,
                      validator: (String? value) =>
                          Validators.name(value, l10n, l10n.fieldState),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.x5),
              AppTextField(
                label: l10n.fieldGstNumber,
                controller: _controller(_SignupField.gstNumber),
                hint: l10n.hintGstNumber,
                trailingLabel: l10n.fieldOptional,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                maxLength: 15,
                isEnabled: !isSubmitting,
                validator: (String? value) =>
                    Validators.optionalGstin(value, l10n),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: Spacing.x6),
              RoleSelector(
                value: _role,
                isEnabled: !isSubmitting,
                onChanged: (UserRole role) => setState(() => _role = role),
              ),
              const SizedBox(height: Spacing.x8),
              AppButton(
                label: l10n.signupSubmit,
                onPressed: _submit,
                isLoading: isSubmitting,
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.x6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              l10n.signupHaveAccount,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: Spacing.x1),
            AppButton(
              label: l10n.signupSignIn,
              onPressed: isSubmitting ? null : () => context.pop(),
              variant: AppButtonVariant.text,
              isExpanded: false,
            ),
          ],
        ),
      ],
    );
  }
}

/// Field identifiers, used to key the controller map.
enum _SignupField {
  email,
  password,
  fullName,
  firmName,
  phone,
  city,
  state,
  gstNumber,
}

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
