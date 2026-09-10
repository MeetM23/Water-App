import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failure_presentation.dart';
import '../../../core/extensions/build_context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_shell.dart';

/// Email and password sign-in.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates the login screen.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final failure = await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (failure != null && mounted) {
      AppSnackbar.error(context, failure.title(context.l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSubmitting = ref.watch(authControllerProvider).isLoading;

    return AuthShell(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppTextField(
                label: l10n.fieldEmail,
                controller: _emailController,
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
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.lock_outline_rounded,
                autofillHints: const <String>[AutofillHints.password],
                isObscured: true,
                isEnabled: !isSubmitting,
                validator: (String? value) =>
                    Validators.required(value, l10n, l10n.fieldPassword),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: Spacing.x8),
              AppButton(
                label: l10n.loginSubmit,
                onPressed: _submit,
                isLoading: isSubmitting,
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.x6),
        // Debug-only way into the design-system gallery. There is no address
        // bar on a handset, so without this the gallery is unreachable on the
        // only platform this app ships to. kDebugMode strips it from every
        // release build, so a dealer never sees it.
        if (kDebugMode)
          AppButton(
            label: 'Design system',
            onPressed: () => context.push(AppRoutes.components),
            variant: AppButtonVariant.text,
            icon: Icons.palette_outlined,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              l10n.loginNoAccount,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: Spacing.x1),
            AppButton(
              label: l10n.loginCreateAccount,
              onPressed: isSubmitting
                  ? null
                  : () {
                      final from = GoRouterState.of(context).uri.queryParameters['from'];
                      final route = from != null && from.isNotEmpty
                          ? '${AppRoutes.signup}?from=${Uri.encodeComponent(from)}'
                          : AppRoutes.signup;
                      context.push(route);
                    },
              variant: AppButtonVariant.text,
              isExpanded: false,
            ),
          ],
        ),
      ],
    );
  }
}
