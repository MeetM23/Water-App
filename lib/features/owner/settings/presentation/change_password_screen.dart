import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure_presentation.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/repositories/supabase_auth_repository.dart';

/// Changes the signed-in owner's password.
///
/// Supabase changes the password of whoever holds the session, so there is no
/// account field here and no way to point this at somebody else. Resetting a
/// dealer's password is a different flow that emails them a link.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final l10n = context.l10n;
    setState(() => _isSaving = true);

    final result = await ref
        .read(authRepositoryProvider)
        .changePassword(_password.text);

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);

    final failure = result.failureOrNull;
    if (failure != null) {
      AppSnackbar.error(context, failure.title(l10n));
      return;
    }

    AppSnackbar.success(context, l10n.passwordChanged);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.passwordTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.x4),
          children: <Widget>[
            AppTextField(
              label: l10n.passwordNewLabel,
              controller: _password,
              isObscured: true,
              autofillHints: const <String>[AutofillHints.newPassword],
              validator: (String? value) => Validators.password(value, l10n),
            ),
            const SizedBox(height: Spacing.x5),
            AppTextField(
              label: l10n.passwordConfirmLabel,
              controller: _confirm,
              isObscured: true,
              autofillHints: const <String>[AutofillHints.newPassword],
              validator: (String? value) =>
                  value == _password.text ? null : l10n.passwordMismatch,
            ),
            const SizedBox(height: Spacing.x8),
            AppButton(
              label: l10n.actionSave,
              onPressed: _save,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
